# Starting the Agent Service

## Quick Start

The Agent Service now automatically loads environment variables from the `.env` file in the project root. You don't need to set them manually!

### Option 1: Using the PowerShell Script (Recommended)

```powershell
cd services\agent
.\start_services.ps1
```

This will start all three services (Rule Engine, Audit, and Agent) automatically.

### Option 2: Manual Start

```powershell
cd services\agent
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

The service will automatically:
- Load `.env` file from project root
- Read `HF_TOKEN` for HuggingFace authentication
- Load model paths from `.env` file
- Configure all settings from `.env`

## Environment Variables

All environment variables should be set in the `.env` file at the project root:

```env
# HuggingFace Authentication
HF_TOKEN=your_huggingface_token_here

# Model Configuration
BASE_MODEL=meta-llama/Llama-2-7b-hf
MEDICAL_ADAPTER_PATH=services/agent/models/llama-lora-safe-0.1
SAFETY_ADAPTER_PATH=services/agent/models/safety-adapter-v1

# Model Loading Configuration
USE_4BIT=true
USE_8BIT=false
USE_ML_MODEL=true

# Service URLs
RULE_ENGINE_URL=http://localhost:8001
AUDIT_URL=http://localhost:8002
```

## Manual Environment Variable Override (Optional)

If you need to override `.env` values temporarily, you can set them in PowerShell:

```powershell
$env:USE_ML_MODEL="true"
$env:MEDICAL_ADAPTER_PATH="services/agent/models/llama-lora-safe-0.1"
$env:SAFETY_ADAPTER_PATH="services/agent/models/safety-adapter-v1"
$env:RULE_ENGINE_URL="http://localhost:8001"
$env:AUDIT_URL="http://localhost:8002"
$env:HF_TOKEN="your_token_here"

cd services\agent
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

**Note**: Environment variables set in PowerShell take precedence over `.env` file values.

## Troubleshooting

### HuggingFace Authentication Error

If you see authentication errors:
1. Verify `HF_TOKEN` is set in `.env` file at project root
2. Check the token is valid and has access to the model
3. Restart the service after updating `.env`

### Model Not Loading

1. Check that `USE_ML_MODEL=true` in `.env`
2. Verify adapter paths exist: `MEDICAL_ADAPTER_PATH` and `SAFETY_ADAPTER_PATH`
3. Check logs for specific error messages

### Performance Optimization

To improve HuggingFace download performance, install the optional `hf_xet` package:

```powershell
pip install "huggingface_hub[hf_xet]"
```

This is optional but recommended for faster model downloads.
