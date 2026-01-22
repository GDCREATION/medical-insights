import os
import logging
from typing import List, Optional, Dict, Any
from pathlib import Path

# Load environment variables from .env file in project root
try:
    from dotenv import load_dotenv
    # Load .env from project root (parent of services/agent)
    project_root = Path(__file__).parent.parent.parent
    env_file = project_root / ".env"
    if env_file.exists():
        load_dotenv(env_file)
        logging.info(f"Loaded .env file from: {env_file}")
    else:
        logging.warning(f".env file not found at: {env_file}")
except ImportError:
    # dotenv not installed, continue without it
    pass
except Exception as e:
    logging.warning(f"Error loading .env file: {e}")

import httpx
from fastapi import FastAPI, Header
from pydantic import BaseModel, Field

# ML Model Service
try:
    from ml_model_service import get_model_service
    ML_MODEL_AVAILABLE = True
except ImportError:
    ML_MODEL_AVAILABLE = False
    logging.warning("ML model service not available. Using fallback functions.")

RULE_ENGINE_URL = os.environ.get("RULE_ENGINE_URL", "http://localhost:8001")
AUDIT_URL = os.environ.get("AUDIT_URL", "http://localhost:8002")
USE_ML_MODEL = os.environ.get("USE_ML_MODEL", "true").lower() == "true" and ML_MODEL_AVAILABLE

app = FastAPI(title="Agent Service", version="0.1.0")
logger = logging.getLogger(__name__)


class SymptomPayload(BaseModel):
    symptoms: List[str] = Field(default_factory=list)
    freeText: Optional[str] = None
    vitals: Optional[Dict[str, Any]] = None
    riskFactors: Optional[Dict[str, Any]] = None
    pregnancyFlag: Optional[bool] = None


class TriageRequest(BaseModel):
    encounterRef: str
    symptoms: SymptomPayload


class TriageResult(BaseModel):
    acuity: str
    emergencyFlag: bool
    rationale: str
    clarifyingQuestions: List[str] = Field(default_factory=list)
    summaryForClinician: str
    safetyWarnings: str
    modelVersion: str = "llama-lora-safe-0.1"
    adapterVersion: str = "safety-adapter-v1"
    ruleVersion: str = "rule-set-v1"
    traceId: Optional[str] = None


async def call_rule_engine(req: TriageRequest) -> dict:
    async with httpx.AsyncClient() as client:
        resp = await client.post(f"{RULE_ENGINE_URL}/evaluate", json=req.dict())
        resp.raise_for_status()
        return resp.json()


async def log_audit(event: dict):
    try:
        async with httpx.AsyncClient() as client:
            await client.post(f"{AUDIT_URL}/events", json=event, timeout=2.0)
    except Exception:
        # Best-effort logging; do not break main flow
        pass


def safety_filter(text: str) -> str:
    forbidden = ["diagnose", "diagnosis", "treat", "prescribe", "cure"]
    filtered = text
    for token in forbidden:
        filtered = filtered.replace(token, "[redacted]")
    return filtered


def _summarise_for_clinician_fallback(rule_result: dict, symptoms: SymptomPayload) -> str:
    """Fallback function when ML model is not available"""
    bullets = [
        f"Acuity: {rule_result.get('acuity')}",
        f"Emergency flag: {rule_result.get('emergencyFlag')}",
        f"Key symptoms: {', '.join(symptoms.symptoms)}",
        f"Rationale: {rule_result.get('rationale')}",
    ]
    summary = "; ".join(bullets)
    summary += "; AI-generated summary for clinician review. Not a diagnosis."
    return safety_filter(summary)


def summarise_for_clinician(rule_result: dict, symptoms: SymptomPayload) -> str:
    """Generate clinician summary using ML model or fallback"""
    if USE_ML_MODEL:
        try:
            model_service = get_model_service()
            if model_service.is_loaded():
                summary = model_service.generate_clinician_summary(
                    rule_result=rule_result,
                    symptoms=symptoms.symptoms,
                    free_text=symptoms.freeText,
                )
                # Apply safety filter as secondary check
                return safety_filter(summary)
            else:
                logger.warning("Model not loaded, using fallback")
        except Exception as e:
            logger.error(f"Error generating summary with ML model: {e}", exc_info=True)
    
    # Fallback to hardcoded function
    return _summarise_for_clinician_fallback(rule_result, symptoms)


def _clarifying_questions_fallback(symptoms: SymptomPayload) -> List[str]:
    """Fallback function when ML model is not available"""
    questions = ["When did the symptoms start?", "Any change in severity?", "Any relevant medical history?"]
    if "chest pain" in [s.lower() for s in symptoms.symptoms]:
        questions.append("Is the chest pain crushing or radiating to arm/jaw?")
    return questions


def clarifying_questions(symptoms: SymptomPayload) -> List[str]:
    """Generate clarifying questions using ML model or fallback"""
    if USE_ML_MODEL:
        try:
            model_service = get_model_service()
            if model_service.is_loaded():
                questions = model_service.generate_clarifying_questions(
                    symptoms=symptoms.symptoms,
                    free_text=symptoms.freeText,
                )
                return questions
            else:
                logger.warning("Model not loaded, using fallback")
        except Exception as e:
            logger.error(f"Error generating questions with ML model: {e}", exc_info=True)
    
    # Fallback to hardcoded function
    return _clarifying_questions_fallback(symptoms)


@app.post("/triage", response_model=TriageResult)
async def triage(request: TriageRequest, x_trace_id: Optional[str] = Header(default=None)):
    trace_id = x_trace_id or request.encounterRef
    rule_result = await call_rule_engine(request)

    summary = summarise_for_clinician(rule_result, request.symptoms)
    safety_warnings = "AI output is advisory only. No diagnoses. Clinician validation required."

    result = TriageResult(
        acuity=rule_result.get("acuity", "unknown"),
        emergencyFlag=rule_result.get("emergencyFlag", False),
        rationale=rule_result.get("rationale", ""),
        clarifyingQuestions=clarifying_questions(request.symptoms),
        summaryForClinician=summary,
        safetyWarnings=safety_warnings,
        traceId=trace_id,
    )

    await log_audit({
        "traceId": trace_id,
        "encounterRef": request.encounterRef,
        "modelVersion": result.modelVersion,
        "adapterVersion": result.adapterVersion,
        "ruleVersion": result.ruleVersion,
        "type": "triage_result",
    })

    return result


@app.on_event("startup")
async def startup_event():
    """Load ML model on startup if available"""
    if USE_ML_MODEL:
        try:
            logger.info("Loading ML model on startup...")
            model_service = get_model_service()
            model_service.load_model()
            logger.info("ML model loaded successfully")
        except Exception as e:
            logger.error(f"Error loading ML model: {e}", exc_info=True)
            logger.warning("Falling back to hardcoded functions")


@app.get("/health")
async def health():
    """Health check endpoint"""
    status = {
        "status": "ok",
        "ml_model_enabled": USE_ML_MODEL,
        "ml_model_loaded": get_model_service().is_loaded() if USE_ML_MODEL and ML_MODEL_AVAILABLE else False,
    }
    return status

