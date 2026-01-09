import os
from typing import List, Optional, Dict, Any

import httpx
from fastapi import FastAPI, Header
from pydantic import BaseModel, Field

RULE_ENGINE_URL = os.environ.get("RULE_ENGINE_URL", "http://localhost:8001")
AUDIT_URL = os.environ.get("AUDIT_URL", "http://localhost:8002")

app = FastAPI(title="Agent Service", version="0.1.0")


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


def summarise_for_clinician(rule_result: dict, symptoms: SymptomPayload) -> str:
    bullets = [
        f"Acuity: {rule_result.get('acuity')}",
        f"Emergency flag: {rule_result.get('emergencyFlag')}",
        f"Key symptoms: {', '.join(symptoms.symptoms)}",
        f"Rationale: {rule_result.get('rationale')}",
    ]
    summary = "; ".join(bullets)
    summary += "; AI-generated summary for clinician review. Not a diagnosis."
    return safety_filter(summary)


def clarifying_questions(symptoms: SymptomPayload) -> List[str]:
    questions = ["When did the symptoms start?", "Any change in severity?", "Any relevant medical history?"]
    if "chest pain" in [s.lower() for s in symptoms.symptoms]:
        questions.append("Is the chest pain crushing or radiating to arm/jaw?")
    return questions


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


@app.get("/health")
async def health():
    return {"status": "ok"}

