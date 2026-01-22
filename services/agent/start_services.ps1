# PowerShell script to start all required services for testing

Write-Host "Starting Medical Insights Services..." -ForegroundColor Green

# Check if Python is available
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    Write-Host "ERROR: Python not found. Please install Python first." -ForegroundColor Red
    exit 1
}

# Start Rule Engine (port 8001)
Write-Host "`n[1/3] Starting Rule Engine on port 8001..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\..\rule-engine'; python -m uvicorn app:app --host 0.0.0.0 --port 8001" -WindowStyle Normal

Start-Sleep -Seconds 3

# Start Audit Service (port 8002)
Write-Host "[2/3] Starting Audit Service on port 8002..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PSScriptRoot\..\audit'; python -m uvicorn app:app --host 0.0.0.0 --port 8002" -WindowStyle Normal

Start-Sleep -Seconds 3

# Start Agent Service (port 8000)
Write-Host "[3/3] Starting Agent Service on port 8000..." -ForegroundColor Yellow
Write-Host "`nAgent Service will start in this window..." -ForegroundColor Cyan
Write-Host "Environment variables will be loaded from .env file in project root" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop all services`n" -ForegroundColor Yellow

cd $PSScriptRoot
# Environment variables are now loaded from .env file automatically
# No need to set them manually - they're loaded by app.py and ml_model_service.py
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
