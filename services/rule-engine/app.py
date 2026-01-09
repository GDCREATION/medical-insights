from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional, Dict, Any

app = FastAPI(title="Rule Engine", version="0.1.0")


class SymptomPayload(BaseModel):
    symptoms: List[str]
    freeText: Optional[str] = None
    vitals: Optional[Dict[str, Any]] = None
    riskFactors: Optional[Dict[str, Any]] = None
    pregnancyFlag: Optional[bool] = None


class TriageRequest(BaseModel):
    encounterRef: str
    symptoms: SymptomPayload


class RuleResult(BaseModel):
    acuity: str
    emergencyFlag: bool
    rationale: str


def evaluate_rules(payload: SymptomPayload) -> RuleResult:
    lower_symptoms = [s.lower() for s in payload.symptoms]
    emergency = False
    rationale_parts = []

    if "chest pain" in lower_symptoms and ("shortness of breath" in lower_symptoms or "dyspnea" in lower_symptoms):
        emergency = True
        rationale_parts.append("Chest pain with breathing difficulty.")
    if "weakness" in lower_symptoms and "numbness" in lower_symptoms:
        emergency = True
        rationale_parts.append("Neurologic deficits reported.")
    if "suicidal ideation" in lower_symptoms:
        emergency = True
        rationale_parts.append("Self-harm risk indicated.")

    acuity = "Emergent" if emergency else "Routine"
    if "fever" in lower_symptoms and "cough" in lower_symptoms:
        acuity = "Urgent"
        rationale_parts.append("Fever with cough.")

    if not rationale_parts:
        rationale_parts.append("No red flags detected; clinician review still required.")

    return RuleResult(
        acuity=acuity,
        emergencyFlag=emergency,
        rationale=" ".join(rationale_parts)
    )


@app.post("/evaluate", response_model=RuleResult)
def evaluate(request: TriageRequest):
    result = evaluate_rules(request.symptoms)
    return result


@app.get("/health")
def health():
    return {"status": "ok"}

