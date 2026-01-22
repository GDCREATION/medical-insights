"""
LoRA Fine-Tuning Script for Medical Triage - Google Colab Version
"""

import json
import os
from typing import Dict

import torch
from datasets import Dataset
from peft import LoraConfig, get_peft_model, prepare_model_for_kbit_training, TaskType
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
    TrainingArguments,
    Trainer,
    DataCollatorForLanguageModeling,
    DataCollatorForSeq2Seq
)

# Configuration - Adjust as needed
MODEL_NAME = "meta-llama/Llama-2-7b-hf"  # Or use a model that doesn't need approval
DATASET_PATH = "/content/medical_triage.jsonl"  # Adjust path if needed
OUTPUT_DIR = "/content/drive/MyDrive/llama-lora-safe-0.1"  # Save to Drive
CHECKPOINT_DIR = "/content/checkpoints"

# LoRA Configuration
LORA_R = 16
LORA_ALPHA = 32
LORA_DROPOUT = 0.1

# Training Configuration
LEARNING_RATE = 3e-4
BATCH_SIZE = 4
GRADIENT_ACCUMULATION = 4
NUM_EPOCHS = 3
WARMUP_STEPS = 100
MAX_SEQ_LENGTH = 1024

# Quantization - Enable for Colab T4 GPU
USE_4BIT = True  # Recommended for Colab free tier
USE_8BIT = False

def load_training_data(file_path: str) -> Dataset:
    """Load JSONL training data and convert to HuggingFace Dataset"""
    data = []
    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            item = json.loads(line.strip())
            data.append(item)
    return Dataset.from_list(data)

def format_prompt(example: Dict) -> tuple:
    """Format training example into prompt-completion format"""
    instruction = example.get("instruction", "")
    input_text = example.get("input", "")
    output = example.get("output", "")

    if input_text:
        prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
    else:
        prompt = f"### Instruction:\n{instruction}\n\n### Response:\n"

    return prompt, output

def preprocess_function(examples: Dict, tokenizer: AutoTokenizer) -> Dict:
    """Tokenize and format examples for training"""
    prompts = []
    completions = []

    for i in range(len(examples["instruction"])):
        prompt, output = format_prompt({
            "instruction": examples["instruction"][i],
            "input": examples.get("input", [""] * len(examples["instruction"]))[i],
            "output": examples.get("output", [""] * len(examples["instruction"]))[i],
        })
        prompts.append(prompt)
        completions.append(output)

    full_texts = [p + c + tokenizer.eos_token for p, c in zip(prompts, completions)]

    model_inputs = tokenizer(
        full_texts,
        max_length=MAX_SEQ_LENGTH,
        truncation=True,
        padding=False,
    )

    labels = []
    for i, text in enumerate(full_texts):
        prompt_len = len(tokenizer(prompts[i], add_special_tokens=False)["input_ids"])
        label = [-100] * prompt_len + model_inputs["input_ids"][i][prompt_len:]
        labels.append(label)

    model_inputs["labels"] = labels
    return model_inputs

# Main training function
print(f"Loading base model: {MODEL_NAME}")
print(f"Loading dataset from: {DATASET_PATH}")
print(f"Output directory: {OUTPUT_DIR}")

# Login to HuggingFace (if needed)
from huggingface_hub import login
# Uncomment and add your token:
# login(token="your_huggingface_token_here")

# Load tokenizer
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token
    tokenizer.pad_token_id = tokenizer.eos_token_id

# Load dataset
print("Loading training data...")
dataset = load_training_data(DATASET_PATH)

# Split dataset (80/10/10)
dataset = dataset.train_test_split(test_size=0.2, seed=42)
val_test = dataset["test"].train_test_split(test_size=0.5, seed=42)
dataset["validation"] = val_test["train"]
dataset["test"] = val_test["test"]

print(f"Train samples: {len(dataset['train'])}")
print(f"Validation samples: {len(dataset['validation'])}")
print(f"Test samples: {len(dataset['test'])}")

# Preprocess dataset
print("Preprocessing dataset...")
tokenized_dataset = dataset.map(
    lambda x: preprocess_function(x, tokenizer),
    batched=True,
    remove_columns=dataset["train"].column_names,
)

# Configure quantization
quantization_config = None
if USE_4BIT:
    quantization_config = BitsAndBytesConfig(
        load_in_4bit=True,
        bnb_4bit_compute_dtype=torch.bfloat16,
        bnb_4bit_quant_type="nf4",
        bnb_4bit_use_double_quant=True,
    )
    print("Using 4-bit quantization")
elif USE_8BIT:
    quantization_config = BitsAndBytesConfig(load_in_8bit=True)
    print("Using 8-bit quantization")

# Load model
print("Loading model...")
model = AutoModelForCausalLM.from_pretrained(
    MODEL_NAME,
    quantization_config=quantization_config,
    device_map="auto",
    torch_dtype=torch.bfloat16 if quantization_config else torch.float32,
    trust_remote_code=True,
)

model.gradient_checkpointing_enable()
model.config.use_cache = False

# Prepare model for training if using quantization
if quantization_config:
    model = prepare_model_for_kbit_training(model)

# Configure LoRA
lora_config = LoraConfig(
    r=LORA_R,
    lora_alpha=LORA_ALPHA,
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    lora_dropout=LORA_DROPOUT,
    bias="none",
    task_type=TaskType.CAUSAL_LM,
)

# Apply LoRA
model = get_peft_model(model, lora_config)
model.print_trainable_parameters()

# Training arguments
training_args = TrainingArguments(
    output_dir=CHECKPOINT_DIR,
    num_train_epochs=NUM_EPOCHS,
    per_device_train_batch_size=BATCH_SIZE,
    per_device_eval_batch_size=BATCH_SIZE,
    gradient_accumulation_steps=GRADIENT_ACCUMULATION,
    learning_rate=LEARNING_RATE,
    warmup_steps=WARMUP_STEPS,
    logging_steps=10,
    eval_steps=50,
    save_steps=100,
    eval_strategy="steps",
    save_strategy="steps",
    load_best_model_at_end=True,
    fp16=False,
    bf16=True,
    report_to="none",
    remove_unused_columns=False,
)

# Data collator
data_collator = DataCollatorForSeq2Seq(
    tokenizer=tokenizer,
    model=model,
    padding=True,
    label_pad_token_id=-100,
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset["train"],
    eval_dataset=tokenized_dataset["validation"],
    data_collator=data_collator,
)

# Train
print("Starting training...")
for n, p in model.named_parameters():
    if "q_proj" in n:
        print("Param:", n)
        print("dtype:", p.dtype)
        print("device:", p.device)
        break
trainer.train()

# Save final model to Google Drive
print(f"Saving model to {OUTPUT_DIR}...")
os.makedirs(OUTPUT_DIR, exist_ok=True)
model.save_pretrained(OUTPUT_DIR)
tokenizer.save_pretrained(OUTPUT_DIR)

# Save model metadata
metadata = {
    "model_version": "llama-lora-safe-0.1",
    "base_model": MODEL_NAME,
    "lora_r": LORA_R,
    "lora_alpha": LORA_ALPHA,
    "lora_dropout": LORA_DROPOUT,
    "training_samples": len(tokenized_dataset["train"]),
    "learning_rate": LEARNING_RATE,
    "batch_size": BATCH_SIZE,
    "num_epochs": NUM_EPOCHS,
}

with open(os.path.join(OUTPUT_DIR, "model_metadata.json"), "w") as f:
    json.dump(metadata, f, indent=2)

print("Training complete!")
print(f"Model saved to: {OUTPUT_DIR}")