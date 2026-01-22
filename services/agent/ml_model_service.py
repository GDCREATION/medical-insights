"""
ML Model Service
Loads base Llama model with medical LoRA adapter and safety adapter
Provides inference interface for generating clinician summaries and clarifying questions
"""

import os
from typing import List, Optional, Dict, Any
import logging
from pathlib import Path

# Initialize logger first
logger = logging.getLogger(__name__)

# Load environment variables from .env file in project root
try:
    from dotenv import load_dotenv
    # Load .env from project root (parent of services/agent)
    project_root = Path(__file__).parent.parent.parent
    env_file = project_root / ".env"
    if env_file.exists():
        load_dotenv(env_file)
        logger.info(f"Loaded .env file from: {env_file}")
    else:
        logger.warning(f".env file not found at: {env_file}")
except ImportError:
    # dotenv not installed, continue without it
    pass
except Exception as e:
    logger.warning(f"Error loading .env file: {e}")

import torch
from peft import PeftModel
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
)

# HuggingFace authentication
try:
    from huggingface_hub import login
    HF_AUTH_AVAILABLE = True
except ImportError:
    HF_AUTH_AVAILABLE = False

logger = logging.getLogger(__name__)

# Configuration
BASE_MODEL = os.environ.get("BASE_MODEL", "meta-llama/Llama-2-7b-hf")
MEDICAL_ADAPTER_PATH = os.environ.get(
    "MEDICAL_ADAPTER_PATH",
    "services/agent/models/llama-lora-safe-0.1"
)
SAFETY_ADAPTER_PATH = os.environ.get(
    "SAFETY_ADAPTER_PATH",
    "services/agent/models/safety-adapter-v1"
)

# Model loading configuration
USE_4BIT = os.environ.get("USE_4BIT", "false").lower() == "true"
USE_8BIT = os.environ.get("USE_8BIT", "false").lower() == "true"
DEVICE_MAP = os.environ.get("DEVICE_MAP", "auto")

# Generation configuration
MAX_NEW_TOKENS = int(os.environ.get("MAX_NEW_TOKENS", "256"))
TEMPERATURE = float(os.environ.get("TEMPERATURE", "0.7"))
TOP_P = float(os.environ.get("TOP_P", "0.9"))
DO_SAMPLE = os.environ.get("DO_SAMPLE", "true").lower() == "true"


class MLModelService:
    """Service for loading and using fine-tuned Llama models"""
    
    def __init__(self):
        self.model = None
        self.tokenizer = None
        self._model_loaded = False
    
    def load_model(self):
        """Load base model with medical and safety adapters"""
        if self._model_loaded:
            logger.info("Model already loaded")
            return
        
        try:
            # Check if HuggingFace token is provided and login if needed
            hf_token = os.environ.get("HF_TOKEN") or os.environ.get("HUGGINGFACE_TOKEN")
            if hf_token and HF_AUTH_AVAILABLE:
                try:
                    login(token=hf_token, add_to_git_credential=False)
                    logger.info("Authenticated with HuggingFace")
                except Exception as e:
                    logger.warning(f"Failed to authenticate with HuggingFace: {e}")
            elif "meta-llama" in BASE_MODEL.lower() or "llama" in BASE_MODEL.lower():
                logger.warning("Llama models require HuggingFace authentication. Set HF_TOKEN environment variable.")
                logger.warning("Or use: huggingface-cli login")
            
            logger.info(f"Loading base model: {BASE_MODEL}")
            
            # Load tokenizer
            self.tokenizer = AutoTokenizer.from_pretrained(
                BASE_MODEL,
                token=hf_token if hf_token else None,
            )
            if self.tokenizer.pad_token is None:
                self.tokenizer.pad_token = self.tokenizer.eos_token
                self.tokenizer.pad_token_id = self.tokenizer.eos_token_id
            
            # Configure quantization if needed
            quantization_config = None
            if USE_4BIT:
                quantization_config = BitsAndBytesConfig(
                    load_in_4bit=True,
                    bnb_4bit_compute_dtype=torch.float16,
                    bnb_4bit_quant_type="nf4",
                    bnb_4bit_use_double_quant=True,
                )
                logger.info("Using 4-bit quantization")
            elif USE_8BIT:
                quantization_config = BitsAndBytesConfig(load_in_8bit=True)
                logger.info("Using 8-bit quantization")
            
            # Load base model
            hf_token = os.environ.get("HF_TOKEN") or os.environ.get("HUGGINGFACE_TOKEN")
            self.model = AutoModelForCausalLM.from_pretrained(
                BASE_MODEL,
                quantization_config=quantization_config,
                device_map=DEVICE_MAP,
                torch_dtype=torch.float16 if quantization_config else torch.float32,
                trust_remote_code=True,
                token=hf_token if hf_token else None,
            )
            
            # Load medical adapter if exists
            if os.path.exists(MEDICAL_ADAPTER_PATH):
                logger.info(f"Loading medical adapter from {MEDICAL_ADAPTER_PATH}")
                self.model = PeftModel.from_pretrained(self.model, MEDICAL_ADAPTER_PATH)
            else:
                logger.warning(f"Medical adapter not found at {MEDICAL_ADAPTER_PATH}")
            
            # Load safety adapter if exists
            if os.path.exists(SAFETY_ADAPTER_PATH):
                logger.info(f"Loading safety adapter from {SAFETY_ADAPTER_PATH}")
                # If we already have a PEFT model, merge the adapters
                if isinstance(self.model, PeftModel):
                    # Load additional adapter
                    self.model.load_adapter(SAFETY_ADAPTER_PATH, adapter_name="safety")
                    # Set both adapters to be active
                    self.model.set_adapter(["default", "safety"])
                else:
                    self.model = PeftModel.from_pretrained(self.model, SAFETY_ADAPTER_PATH)
            else:
                logger.warning(f"Safety adapter not found at {SAFETY_ADAPTER_PATH}")
            
            self.model.eval()
            self._model_loaded = True
            logger.info("Model loaded successfully")
            
        except Exception as e:
            logger.error(f"Error loading model: {e}", exc_info=True)
            raise
    
    def _generate(self, prompt: str, max_tokens: int = MAX_NEW_TOKENS) -> str:
        """Generate text from prompt using the loaded model"""
        if not self._model_loaded:
            raise RuntimeError("Model not loaded. Call load_model() first.")
        
        try:
            # Tokenize input
            inputs = self.tokenizer(
                prompt,
                return_tensors="pt",
                truncation=True,
                max_length=1024,
            ).to(self.model.device)
            
            # Generate
            with torch.no_grad():
                outputs = self.model.generate(
                    **inputs,
                    max_new_tokens=max_tokens,
                    temperature=TEMPERATURE,
                    top_p=TOP_P,
                    do_sample=DO_SAMPLE,
                    pad_token_id=self.tokenizer.pad_token_id,
                    eos_token_id=self.tokenizer.eos_token_id,
                )
            
            # Decode output
            generated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
            
            # Extract only the generated part (remove prompt)
            if prompt in generated_text:
                generated_text = generated_text.split(prompt, 1)[1].strip()
            
            return generated_text
            
        except Exception as e:
            logger.error(f"Error during generation: {e}", exc_info=True)
            raise
    
    def generate_clinician_summary(
        self,
        rule_result: Dict[str, Any],
        symptoms: List[str],
        free_text: Optional[str] = None,
    ) -> str:
        """Generate clinician summary from rule engine result and symptoms"""
        instruction = "Generate a non-diagnostic clinician summary for these symptoms and rule engine result."
        
        # Format input
        symptoms_str = ", ".join(symptoms) if symptoms else "No specific symptoms listed"
        input_text = f"Symptoms: {symptoms_str}"
        if free_text:
            input_text += f". Additional information: {free_text}"
        input_text += f". Acuity: {rule_result.get('acuity', 'unknown')}"
        input_text += f". Emergency: {rule_result.get('emergencyFlag', False)}"
        input_text += f". Rationale: {rule_result.get('rationale', '')}"
        
        prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
        
        summary = self._generate(prompt, max_tokens=MAX_NEW_TOKENS)
        
        # Ensure summary includes disclaimer
        if "not a diagnosis" not in summary.lower() and "advisory" not in summary.lower():
            summary += " AI-generated summary for clinician review. Not a diagnosis."
        
        return summary.strip()
    
    def generate_clarifying_questions(
        self,
        symptoms: List[str],
        free_text: Optional[str] = None,
    ) -> List[str]:
        """Generate clarifying questions based on symptoms"""
        instruction = "Generate clarifying questions for these symptoms."
        
        symptoms_str = ", ".join(symptoms) if symptoms else "No specific symptoms listed"
        input_text = f"Symptoms: {symptoms_str}"
        if free_text:
            input_text += f". Additional information: {free_text}"
        
        prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
        
        response = self._generate(prompt, max_tokens=128)
        
        # Parse questions (assume one per line or separated by newlines)
        questions = []
        for line in response.strip().split("\n"):
            line = line.strip()
            if line:
                # Remove numbering if present (e.g., "1. Question" -> "Question")
                if line and line[0].isdigit() and ". " in line:
                    line = line.split(". ", 1)[1]
                if line and line[0] == "-":
                    line = line[1:].strip()
                if line:
                    questions.append(line)
        
        # Fallback to default questions if generation fails
        if not questions:
            questions = [
                "When did the symptoms start?",
                "Any change in severity?",
                "Any relevant medical history?",
            ]
        
        return questions[:5]  # Limit to 5 questions
    
    def is_loaded(self) -> bool:
        """Check if model is loaded"""
        return self._model_loaded


# Global service instance
_model_service: Optional[MLModelService] = None


def get_model_service() -> MLModelService:
    """Get or create global model service instance"""
    global _model_service
    if _model_service is None:
        _model_service = MLModelService()
    return _model_service


def load_model():
    """Load model (convenience function)"""
    service = get_model_service()
    if not service.is_loaded():
        service.load_model()
