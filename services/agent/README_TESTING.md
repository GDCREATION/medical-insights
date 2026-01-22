# Testing the Triage API

## Quick Start

### Step 1: Start All Services

**Option A: Use the PowerShell script (Windows)**
```powershell
cd services/agent
.\start_services.ps1
```

**Option B: Start manually in separate terminals**

**Terminal 1 - Rule Engine:**
```powershell
cd services/rule-engine
python -m uvicorn app:app --host 0.0.0.0 --port 8001
```

**Terminal 2 - Audit Service:**
```powershell
cd services/audit
python -m uvicorn app:app --host 0.0.0.0 --port 8002
```

**Terminal 3 - Agent Service:**
```powershell
cd services/agent
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

### Step 2: Wait for Services to Start

Wait about 10-30 seconds for:
- Rule Engine to start (port 8001)
- Audit Service to start (port 8002)
- Agent Service to start and load ML models (port 8000) - this may take 1-2 minutes if loading models

### Step 3: Run Tests

**Option A: Use the test script**
```powershell
cd services/agent
python test_triage_api.py
```

**Option B: Test manually with curl**

**Health Check:**
```powershell
curl http://localhost:8000/health
```

**Triage API:**
```powershell
curl -X POST http://localhost:8000/triage `
  -H "Content-Type: application/json" `
  -H "X-Trace-Id: test-123" `
  -d '{\"encounterRef\": \"enc-001\", \"symptoms\": {\"symptoms\": [\"chest pain\", \"shortness of breath\"]}}'
```

**Option C: Use Python requests**
```python
import requests

# Health check
response = requests.get("http://localhost:8000/health")
print(response.json())

# Triage request
response = requests.post(
    "http://localhost:8000/triage",
    json={
        "encounterRef": "enc-001",
        "symptoms": {
            "symptoms": ["chest pain", "shortness of breath"],
            "freeText": "Started 30 minutes ago"
        }
    },
    headers={"X-Trace-Id": "test-123"}
)
print(response.json())
```

## Expected Response

```json
{
  "acuity": "Emergent",
  "emergencyFlag": true,
  "rationale": "Chest pain with breathing difficulty.",
  "clarifyingQuestions": [
    "When did the symptoms start?",
    "Is the chest pain crushing or radiating to arm/jaw?",
    ...
  ],
  "summaryForClinician": "Acuity level: Emergent. Emergency flag: True...",
  "safetyWarnings": "AI output is advisory only. No diagnoses...",
  "modelVersion": "llama-lora-safe-0.1",
  "adapterVersion": "safety-adapter-v1",
  "ruleVersion": "rule-set-v1",
  "traceId": "test-123"
}
```

## Troubleshooting

**Service not starting:**
- Check if ports 8000, 8001, 8002 are already in use
- Install dependencies: `pip install -r requirements.txt`

**Model not loading:**
- Check model paths in environment variables
- Verify models exist in `services/agent/models/`
- Check logs for loading errors

**Connection errors:**
- Ensure all three services are running
- Check firewall settings
- Verify service URLs in environment variables
