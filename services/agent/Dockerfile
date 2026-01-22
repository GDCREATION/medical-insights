FROM python:3.11-slim

# Install system dependencies for ML libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py .
COPY ml_model_service.py .
COPY prompts.py .

# Copy models directory (will be empty initially, can mount as volume in production)
RUN mkdir -p models/llama-lora-safe-0.1 models/safety-adapter-v1
COPY models/ models/ || true

# Set environment variables
ENV USE_ML_MODEL=true
ENV BASE_MODEL=meta-llama/Llama-2-7b-hf
ENV MEDICAL_ADAPTER_PATH=models/llama-lora-safe-0.1
ENV SAFETY_ADAPTER_PATH=models/safety-adapter-v1
ENV USE_4BIT=true
ENV USE_8BIT=false

EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]

