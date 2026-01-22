# HuggingFace Authentication Guide

## Problem
The Llama models require HuggingFace authentication because they are gated repositories.

## Solution Options

### Option 1: Use HuggingFace Token (Recommended)

**Step 1: Get your HuggingFace token**
1. Go to https://huggingface.co/settings/tokens
2. Create a new token (read access is sufficient)
3. Copy the token

**Step 2: Set the token as environment variable**

**PowerShell:**
```powershell
$env:HF_TOKEN="your_token_here"
# Or
$env:HUGGINGFACE_TOKEN="your_token_here"
```

**Windows Command Prompt:**
```cmd
set HF_TOKEN=your_token_here
```

**Linux/Mac:**
```bash
export HF_TOKEN="your_token_here"
```

**Step 3: Restart the Agent Service**
```powershell
cd services\agent
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

### Option 2: Use HuggingFace CLI Login

**Step 1: Install huggingface_hub**
```powershell
pip install huggingface_hub
```

**Step 2: Login**
```powershell
huggingface-cli login
```
Enter your token when prompted.

**Step 3: Restart the Agent Service**

### Option 3: Use a Different Base Model (No Authentication Required)

If you don't have HuggingFace access, use an open model:

**PowerShell:**
```powershell
$env:BASE_MODEL="microsoft/DialoGPT-medium"
# Or
$env:BASE_MODEL="gpt2"
# Or
$env:BASE_MODEL="distilgpt2"
```

**Note:** You'll need to retrain your adapters if you change the base model.

### Option 4: Use Local Model Path

If you've downloaded the model locally:

```powershell
$env:BASE_MODEL="C:\path\to\your\local\llama\model"
```

## Quick Start Command

```powershell
# Set your HuggingFace token
$env:HF_TOKEN="hf_your_token_here"

# Set model paths
$env:MEDICAL_ADAPTER_PATH="services/agent/models/llama-lora-safe-0.1"
$env:SAFETY_ADAPTER_PATH="services/agent/models/safety-adapter-v1"
$env:USE_ML_MODEL="true"

# Start the service
cd services\agent
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
```

## Verify Authentication

After starting the service, check the logs. You should see:
```
INFO: Authenticated with HuggingFace
INFO: Loading base model: meta-llama/Llama-2-7b-hf
```

If you see authentication errors, verify:
1. Token is correct
2. Token has read access
3. You have access to the Llama model on HuggingFace (may need to request access)

## Request Access to Llama Models

1. Go to https://huggingface.co/meta-llama/Llama-2-7b-hf
2. Click "Request access"
3. Fill out the form
4. Wait for approval (usually quick)
5. Once approved, use your token to access
