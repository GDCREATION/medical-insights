import hashlib
import json
import time
from typing import List, Optional

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="Audit Service", version="0.1.0")


class AuditEvent(BaseModel):
    traceId: str
    encounterRef: str
    modelVersion: Optional[str] = None
    adapterVersion: Optional[str] = None
    ruleVersion: Optional[str] = None
    type: str
    timestamp: float = None
    hash: Optional[str] = None
    prevHash: Optional[str] = None


ledger: List[AuditEvent] = []


def compute_hash(event: AuditEvent, prev_hash: str) -> str:
    payload = event.dict()
    payload["prevHash"] = prev_hash
    payload_str = json.dumps(payload, sort_keys=True)
    return hashlib.sha256(payload_str.encode("utf-8")).hexdigest()


@app.post("/events")
def add_event(event: AuditEvent):
    prev_hash = ledger[-1].hash if ledger else ""
    event.timestamp = time.time()
    event.prevHash = prev_hash
    event.hash = compute_hash(event, prev_hash)
    ledger.append(event)
    return {"status": "logged", "hash": event.hash}


@app.get("/events")
def list_events():
    return ledger


@app.get("/health")
def health():
    return {"status": "ok"}

