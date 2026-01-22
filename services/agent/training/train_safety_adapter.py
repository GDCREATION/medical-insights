
sudo apt-get update -y
sudo apt-get install python3.10 python3.10-distutils -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

import torch, os, sys

print("Python version:", sys.version)
print("CUDA available:", torch.cuda.is_available())
if torch.cuda.is_available():
    print("GPU:", torch.cuda.get_device_name(0))

pip install -U transformers accelerate bitsandbytes

import os, torch
from transformers import AutoModelForCausalLM, AutoTokenizer

# Allow online access ONLY here
os.environ.pop("HF_HUB_ENABLE_HF_TRANSFER", None)
os.environ.pop("HF_HUB_DISABLE_PROGRESS_BARS", None)

BASE_MODEL = "meta-llama/Llama-2-7b-hf"

# Tokenizer
tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)

# Full model download (no quantization here)
model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    torch_dtype=torch.float16,
    device_map=None,
    local_files_only=False,
)

print("✅ Base model fully downloaded")

del model
torch.cuda.empty_cache()

import os

os.environ["HF_HUB_ENABLE_HF_TRANSFER"] = "0"
os.environ["HF_HUB_DISABLE_PROGRESS_BARS"] = "1"

print("🔒 Offline mode enabled")

BASE_MODEL = "meta-llama/Llama-2-7b-hf"

MEDICAL_ADAPTER_PATH = "/content/drive/MyDrive/llama-lora-safe-0.1"
SAFETY_DATASET_PATH = "/content/safety_constraints.jsonl"

OUTPUT_DIR = "/content/drive/MyDrive/safety-adapter-v1"
CHECKPOINT_DIR = "/content/checkpoints/safety"

# LoRA (Safety Adapter)
LORA_R = 8
LORA_ALPHA = 16
LORA_DROPOUT = 0.1

# Training
LEARNING_RATE = 2e-4
BATCH_SIZE = 2
GRADIENT_ACCUMULATION = 8
NUM_EPOCHS = 5
WARMUP_STEPS = 50
MAX_SEQ_LENGTH = 1024

USE_4BIT = True

import json
from datasets import Dataset

def load_training_data(file_path):
    data = []
    with open(file_path, "r", encoding="utf-8") as f:
        for line in f:
            data.append(json.loads(line))
    return Dataset.from_list(data)

dataset = load_training_data(SAFETY_DATASET_PATH)

dataset = dataset.train_test_split(test_size=0.2, seed=42)
val_test = dataset["test"].train_test_split(test_size=0.5, seed=42)
dataset["validation"] = val_test["train"]
dataset["test"] = val_test["test"]

print("Train:", len(dataset["train"]))
print("Validation:", len(dataset["validation"]))
print("Test:", len(dataset["test"]))

from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL)
tokenizer.pad_token = tokenizer.eos_token
tokenizer.padding_side = "right"

def format_safety_prompt(example):
    instruction = (
        "Generate a safe, non-diagnostic response that avoids diagnostic "
        "terms like 'diagnose', 'treat', 'prescribe', or 'cure'."
    )
    prompt = (
        f"### Instruction:\n{instruction}\n\n"
        f"### Input:\n{example['input']}\n\n### Response:\n"
    )
    return prompt, example["safe_output"]

def preprocess_fn(examples):
    prompts, outputs = [], []
    for i in range(len(examples["input"])):
        p, o = format_safety_prompt({
            "input": examples["input"][i],
            "safe_output": examples["safe_output"][i],
        })
        prompts.append(p)
        outputs.append(o)

    texts = [p + o + tokenizer.eos_token for p, o in zip(prompts, outputs)]
    enc = tokenizer(texts, truncation=True, max_length=MAX_SEQ_LENGTH)

    labels = []
    for i, p in enumerate(prompts):
        p_len = len(tokenizer(p, add_special_tokens=False)["input_ids"])
        labels.append([-100] * p_len + enc["input_ids"][i][p_len:])

    enc["labels"] = labels
    return enc

tokenized_dataset = dataset.map(
    preprocess_fn,
    batched=True,
    remove_columns=dataset["train"].column_names,
)

import torch
from transformers import AutoModelForCausalLM, BitsAndBytesConfig
from peft import prepare_model_for_kbit_training

quant_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,
)

model = AutoModelForCausalLM.from_pretrained(
    BASE_MODEL,
    quantization_config=quant_config,
    device_map=None,
    torch_dtype=torch.bfloat16,
    local_files_only=True,
)

model.gradient_checkpointing_enable()
model.config.use_cache = False
model = prepare_model_for_kbit_training(model)

print("✅ Base model loaded (offline, 4-bit)")

from peft import PeftModel, LoraConfig, TaskType

# Load medical adapter (frozen)
model = PeftModel.from_pretrained(
    model,
    MEDICAL_ADAPTER_PATH,
    adapter_name="medical",
    is_trainable=False,
)
model.set_adapter("medical")

# Add safety adapter (trainable)
safety_config = LoraConfig(
    r=LORA_R,
    lora_alpha=LORA_ALPHA,
    lora_dropout=LORA_DROPOUT,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    bias="none",
    task_type=TaskType.CAUSAL_LM,
)

model.add_adapter("safety", safety_config)
model.set_adapter("safety")
model.print_trainable_parameters()

from transformers import TrainingArguments, Trainer, DataCollatorForSeq2Seq

training_args = TrainingArguments(
    output_dir=CHECKPOINT_DIR,
    num_train_epochs=NUM_EPOCHS,
    per_device_train_batch_size=BATCH_SIZE,
    gradient_accumulation_steps=GRADIENT_ACCUMULATION,
    learning_rate=LEARNING_RATE,
    warmup_steps=WARMUP_STEPS,
    logging_steps=10,
    save_steps=100,
    eval_strategy="no",
    save_strategy="steps",
    bf16=True,
    fp16=False,
    report_to="none",
    remove_unused_columns=False,
)

data_collator = DataCollatorForSeq2Seq(
    tokenizer=tokenizer,
    model=model,
    label_pad_token_id=-100,
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset["train"],
    data_collator=data_collator,
)

trainer.train()

import os, json

os.makedirs(OUTPUT_DIR, exist_ok=True)

model.save_pretrained(OUTPUT_DIR, adapter_names=["safety"])
tokenizer.save_pretrained(OUTPUT_DIR)

metadata = {
    "adapter": "safety-adapter-v1",
    "base_model": BASE_MODEL,
    "medical_adapter": MEDICAL_ADAPTER_PATH,
    "epochs": NUM_EPOCHS,
}

with open(os.path.join(OUTPUT_DIR, "adapter_metadata.json"), "w") as f:
    json.dump(metadata, f, indent=2)

print("✅ Safety adapter saved")

prompt = "I have chest pain and fever. What should I do?"

inputs = tokenizer(prompt, return_tensors="pt").to("cuda")
with torch.no_grad():
    out = model.generate(**inputs, max_new_tokens=100)

print(tokenizer.decode(out[0], skip_special_tokens=True))