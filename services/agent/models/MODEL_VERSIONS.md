# Model Versions Tracking

This document tracks model and adapter versions used in the medical insights triage system.

## Version Format

- **Model Version**: `llama-lora-safe-{major}.{minor}`
- **Adapter Version**: `safety-adapter-v{major}`
- **Rule Version**: `rule-set-v{major}`

## Current Versions

| Component | Version | Status | Date | Description |
|-----------|---------|--------|------|-------------|
| Medical LoRA Adapter | `llama-lora-safe-0.1` | Development | TBD | Initial medical triage fine-tuning |
| Safety Adapter | `safety-adapter-v1` | Development | TBD | Initial safety constraint adapter |
| Rule Engine | `rule-set-v1` | Production | TBD | Deterministic triage rules |

## Version History

### Medical LoRA Adapter

#### llama-lora-safe-0.1
- **Release Date**: TBD
- **Base Model**: Llama 2 7B / Llama 3 8B
- **LoRA Config**: r=16-64, alpha=32-128, dropout=0.1
- **Training Data**: Medical triage scenarios (clinician summaries, clarifying questions)
- **Training Epochs**: 3-5
- **Learning Rate**: 2e-4 to 5e-4
- **Notes**: Initial version for medical triage use cases

### Safety Adapter

#### safety-adapter-v1
- **Release Date**: TBD
- **Base Adapter**: Works with `llama-lora-safe-0.1`
- **LoRA Config**: r=8-16, alpha=16-32, dropout=0.1
- **Training Data**: Safety constraint examples (advisory vs. diagnostic language)
- **Training Epochs**: 5
- **Learning Rate**: 2e-4
- **Notes**: Prevents diagnostic language; enforces advisory-only outputs

## Version Compatibility

| Medical Adapter | Safety Adapter | Compatible | Notes |
|----------------|----------------|------------|-------|
| llama-lora-safe-0.1 | safety-adapter-v1 | Yes | Initial compatible pair |

## Deployment Status

### Production
- Rule Engine: `rule-set-v1` (Active)

### Development/Staging
- Medical Adapter: `llama-lora-safe-0.1` (Under evaluation)
- Safety Adapter: `safety-adapter-v1` (Under evaluation)

## Upgrade Path

### Future Versions (Planned)

#### llama-lora-safe-0.2
- **Planned Improvements**:
  - Expanded training dataset
  - Better question generation
  - Improved summary coherence
  - Performance optimizations

#### safety-adapter-v2
- **Planned Improvements**:
  - Enhanced safety constraint coverage
  - Better detection of diagnostic language variants
  - Improved advisory phrasing

## Model Metadata Location

- Medical Adapter: `services/agent/models/llama-lora-safe-0.1/model_metadata.json`
- Safety Adapter: `services/agent/models/safety-adapter-v1/adapter_metadata.json`

## Audit Tracking

All model versions are tracked in the audit service:
- `modelVersion`: Medical adapter version (e.g., `llama-lora-safe-0.1`)
- `adapterVersion`: Safety adapter version (e.g., `safety-adapter-v1`)
- `ruleVersion`: Rule engine version (e.g., `rule-set-v1`)

Query audit logs to see which model versions were used for specific triage requests.

## Testing Status

| Version | Safety Tests | Medical Accuracy Tests | Performance Tests | Status |
|---------|--------------|------------------------|-------------------|--------|
| llama-lora-safe-0.1 + safety-adapter-v1 | Pending | Pending | Pending | Under Development |

## Notes

- Model versions are set in `services/agent/app.py` (`TriageResult` model)
- Version tracking is automatic via audit service
- All model invocations log model and adapter versions
- Model versions should be updated when deploying new trained models

## Maintenance

- Update this document when deploying new model versions
- Document breaking changes between versions
- Maintain backward compatibility where possible
- Archive old model versions for audit purposes
