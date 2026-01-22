# Agent Service - Medical Triage AI

The Agent Service provides AI-powered clinician summaries and clarifying questions for medical triage workflows. It integrates fine-tuned Llama models with deterministic rule engine outputs to generate safe, non-diagnostic advisory content.

## Features

- **Medical LoRA Adapter** (`llama-lora-safe-0.1`): Fine-tuned for medical triage scenarios
- **Safety Adapter** (`safety-adapter-v1`): Prevents diagnostic language in outputs
- **Rule Engine Integration**: Always runs deterministic triage rules first
- **Safety Filtering**: Post-processing removes any diagnostic terms
- **Audit Logging**: All model versions and outputs are logged

## Model Architecture

The service uses two LoRA adapters on top of a base Llama model:

1. **Medical Adapter**: Trained on medical triage scenarios to generate clinician summaries and clarifying questions
2. **Safety Adapter**: Trained on safety constraints to avoid diagnostic language

Both adapters are loaded simultaneously during inference to ensure medical accuracy and safety compliance.

## Installation

### Dependencies

Install required Python packages:

```bash
pip install -r requirements.txt
```

Key dependencies:
- `transformers>=4.35.0`: HuggingFace transformers for model loading
- `peft>=0.7.0`: Parameter-Efficient Fine-Tuning for LoRA adapters
- `torch>=2.1.0`: PyTorch for model inference
- `bitsandbytes>=0.41.0`: Optional quantization support
- `accelerate>=0.25.0`: Model loading acceleration

### Model Weights

Model weights are expected in:
- `models/llama-lora-safe-0.1/`: Medical LoRA adapter
- `models/safety-adapter-v1/`: Safety adapter

For production, mount these as volumes or download from model storage.

## Configuration

### Environment Variables

- `BASE_MODEL`: Base Llama model (default: `meta-llama/Llama-2-7b-hf`)
- `MEDICAL_ADAPTER_PATH`: Path to medical adapter (default: `models/llama-lora-safe-0.1`)
- `SAFETY_ADAPTER_PATH`: Path to safety adapter (default: `models/safety-adapter-v1`)
- `USE_ML_MODEL`: Enable ML model (default: `true`)
- `USE_4BIT`: Enable 4-bit quantization (default: `false`)
- `USE_8BIT`: Enable 8-bit quantization (default: `false`)
- `RULE_ENGINE_URL`: Rule engine service URL (default: `http://localhost:8001`)
- `AUDIT_URL`: Audit service URL (default: `http://localhost:8002`)

### Model Loading

The service automatically loads models on startup if `USE_ML_MODEL=true`. If models are not available, it falls back to hardcoded functions.

## Usage

### API Endpoints

#### POST /triage

Generate triage result with AI-powered summaries:

```bash
curl -X POST http://localhost:8000/triage \
  -H "Content-Type: application/json" \
  -H "X-Trace-Id: trace-123" \
  -d '{
    "encounterRef": "enc-123",
    "symptoms": {
      "symptoms": ["chest pain", "shortness of breath"],
      "freeText": "Started 30 minutes ago"
    }
  }'
```

Response includes:
- `acuity`: Triage acuity level (Emergent/Urgent/Routine)
- `emergencyFlag`: Emergency flag from rule engine
- `rationale`: Rationale from rule engine
- `clarifyingQuestions`: AI-generated clarifying questions
- `summaryForClinician`: AI-generated clinician summary
- `safetyWarnings`: Safety disclaimers
- `modelVersion`: Medical adapter version
- `adapterVersion`: Safety adapter version

#### GET /health

Health check endpoint:

```bash
curl http://localhost:8000/health
```

Returns:
- `status`: Service status
- `ml_model_enabled`: Whether ML model is enabled
- `ml_model_loaded`: Whether ML model is loaded

## Training

### Fine-Tune Medical Adapter

Train the medical LoRA adapter on medical triage data:

```bash
cd training
python finetune_lora.py
```

Configuration via environment variables:
- `BASE_MODEL`: Base model to fine-tune
- `DATASET_PATH`: Path to training data (JSONL format)
- `OUTPUT_DIR`: Output directory for adapter
- `LORA_R`: LoRA rank (default: 16)
- `LORA_ALPHA`: LoRA alpha (default: 32)
- `LEARNING_RATE`: Learning rate (default: 3e-4)
- `NUM_EPOCHS`: Training epochs (default: 3)

### Train Safety Adapter

Train the safety adapter on safety constraint data:

```bash
cd training
python train_safety_adapter.py
```

Configuration via environment variables:
- `BASE_MODEL`: Base model
- `MEDICAL_ADAPTER_PATH`: Path to medical adapter (if training on top)
- `SAFETY_DATASET_PATH`: Path to safety training data
- `OUTPUT_DIR`: Output directory for safety adapter
- `LORA_R`: LoRA rank (default: 8)
- `LEARNING_RATE`: Learning rate (default: 2e-4)
- `NUM_EPOCHS`: Training epochs (default: 5)

## Testing

Run tests:

```bash
pytest tests/ -v
```

### Test Suites

- `tests/test_safety.py`: Safety evaluation tests
- `tests/test_medical_outputs.py`: Medical accuracy tests

### Running Specific Tests

```bash
# Run safety tests only
pytest tests/test_safety.py -v

# Run medical accuracy tests only
pytest tests/test_medical_outputs.py -v

# Run tests that require ML model
pytest tests/ -v -m ml_model
```

## Deployment

### Docker

Build Docker image:

```bash
docker build -t agent-service .
```

Run container:

```bash
docker run -p 8000:8000 \
  -e USE_ML_MODEL=true \
  -e BASE_MODEL=meta-llama/Llama-2-7b-hf \
  -v ./models:/app/models \
  agent-service
```

### Docker Compose

The service is included in the main `docker-compose.yml`. Ensure model weights are available or mount them as volumes.

## Safety & Compliance

- **Non-Diagnostic**: Model explicitly avoids diagnostic language
- **Clinician Review**: All outputs require clinician validation
- **Audit Logging**: Model versions and outputs are logged for compliance
- **Safety Filter**: Post-processing removes any diagnostic terms
- **Fallback**: Hardcoded functions when model unavailable

## Model Versioning

Model versions are tracked in:
- `models/MODEL_VERSIONS.md`: Version history and compatibility
- `models/MODEL_CARD.md`: Model card with training details

## Troubleshooting

### Model Not Loading

- Check model weights are in correct directories
- Verify `BASE_MODEL` environment variable
- Check logs for model loading errors
- Service falls back to hardcoded functions if model unavailable

### Out of Memory

- Enable quantization: `USE_4BIT=true` or `USE_8BIT=true`
- Use smaller base model (7B instead of 13B/70B)
- Reduce `MAX_NEW_TOKENS` in generation config

### Slow Inference

- Enable quantization for faster inference
- Use GPU if available (set `DEVICE_MAP=auto`)
- Reduce `MAX_NEW_TOKENS` for shorter outputs

## Documentation

- `models/MODEL_CARD.md`: Model card with training details
- `models/MODEL_VERSIONS.md`: Version tracking and compatibility
- `prompts.py`: Prompt templates for generation tasks
- `ml_model_service.py`: Model loading and inference service

## License

See main project LICENSE file.
