# Patient Triage & Symptom Agentic AI System

This repository contains a production-minded scaffold for a safe, non-diagnostic patient triage and symptom analysis platform. It implements service boundaries from the blueprint: Angular frontend placeholder, Spring Boot API gateway, FastAPI agent service, deterministic rule engine, audit service, PostgreSQL, and OIDC mock. AI outputs are advisory only and require clinician validation.

## Services
- `frontend/` (placeholder): role-based UI placeholder with consent and safety disclaimers.
- `backend/gateway/` (Spring Boot): OAuth2 resource server, RBAC-ready, orchestrates triage, persists encounters (in-memory demo), calls agent service.
- `services/agent/` (FastAPI): planner + tool stub, calls deterministic rule engine first, summarizes with safety filter, logs to audit.
- `services/rule-engine/` (FastAPI): deterministic rules for acuity and emergency flags.
- `services/audit/` (FastAPI): append-only hash-chained audit log.
- `deploy/k8s/`: Kubernetes manifests for namespace, gateway, agent, rule engine, audit, postgres, frontend.

## Run locally (Docker Compose)
```sh
docker compose up --build
# Gateway available at http://localhost:8080
# Agent at http://localhost:8000, Rule engine at 8001, Audit at 8002, Frontend placeholder at 4200
```

Sample flow (happy path):
1) `POST /api/encounters` with `{ "patientId": "demo", "consentToken": "token" }`.
2) `POST /api/encounters/{id}/symptoms` with structured symptoms.
3) `POST /api/encounters/{id}/triage` (gateway calls agent → rule engine first).
4) `POST /api/encounters/{id}/clinician-review` for clinician approval/override.

## Kubernetes (reference)
```sh
kubectl apply -f deploy/k8s/namespace.yaml
kubectl apply -f deploy/k8s/postgres.yaml
kubectl apply -f deploy/k8s/rule-engine.yaml
kubectl apply -f deploy/k8s/audit.yaml
kubectl apply -f deploy/k8s/agent.yaml
kubectl apply -f deploy/k8s/gateway.yaml
kubectl apply -f deploy/k8s/frontend.yaml
```
Images are referenced as `:latest` for brevity—replace with registry-published, versioned images and configure mTLS, ingress, WAF, and secrets via your preferred secret manager.

## Safety & Compliance Notes
- No diagnoses or treatments are produced; language remains cautious and advisory.
- Deterministic rule engine runs before any summarization; emergencies are escalated.
- All prompts/tool calls are intended to be logged; PHI must be redacted before logging in production.
- OIDC mock is for local development; wire to your real IdP for production with short-lived JWTs.

## Next steps
- Swap placeholder frontend with a real Angular app using consent-first flows and role-based dashboards.
- Replace in-memory storage in gateway with PostgreSQL persistence and audit pointers.
- Add real JWT validation keys, mTLS between services, and production-grade observability (OTel).

Java download : winget install Amazon.Corretto.17.JDK --accept-package-agreements --accept-source-agreements