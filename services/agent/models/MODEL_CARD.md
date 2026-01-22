# Model Card: Llama-Lora-Safe-0.1 with Safety-Adapter-V1

## Model Details

### Model Information
- **Model Version**: `llama-lora-safe-0.1`
- **Safety Adapter Version**: `safety-adapter-v1`
- **Base Model**: Llama 2 7B (or Llama 3 8B)
- **Fine-tuning Method**: LoRA (Low-Rank Adaptation)
- **Primary Use Case**: Medical triage assistant with non-diagnostic advisory outputs

## Model Description

This model is a fine-tuned version of Llama 2/3 designed for medical triage use cases. It consists of two LoRA adapters:

1. **Medical LoRA Adapter (`llama-lora-safe-0.1`)**: Fine-tuned on medical triage scenarios to generate clinician summaries and clarifying questions based on symptoms and rule engine outputs.

2. **Safety Adapter (`safety-adapter-v1`)**: Trained on safety constraint data to prevent the model from using diagnostic language (e.g., "diagnose", "treat", "prescribe", "cure"). This adapter ensures all outputs remain advisory and non-diagnostic.

## Intended Use Cases

### Primary Use
- Generate non-diagnostic clinician summaries from rule engine outputs and patient symptoms
- Generate relevant clarifying questions based on symptom descriptions
- Assist in medical triage workflows where outputs require clinician review

### Out of Scope
- **NOT for direct patient diagnosis**
- **NOT for treatment recommendations**
- **NOT for prescription advice**
- **NOT for standalone clinical decision-making**

## Training Data

### Medical Triage Dataset
- **Source**: Curated medical triage scenarios (synthetic and/or de-identified)
- **Format**: JSONL with instruction-input-output triplets
- **Content**: 
  - Symptom descriptions → clinician summary generation
  - Rule engine outputs → natural language summaries
  - Symptom lists → clarifying questions generation
- **Size**: Varies by training run
- **Splits**: 80/10/10 (train/validation/test)

### Safety Constraint Dataset
- **Source**: Safety constraint examples
- **Content**: Pairs of forbidden diagnostic language vs. safe advisory language
- **Purpose**: Train model to avoid diagnostic terminology

## Model Architecture

### Base Model
- **Architecture**: Llama 2 7B or Llama 3 8B
- **Parameters**: 7-8 billion
- **Context Length**: 4096 tokens

### LoRA Configuration

#### Medical Adapter
- **Rank (r)**: 16-64
- **Alpha**: 32-128
- **Target Modules**: q_proj, v_proj, k_proj, o_proj
- **Dropout**: 0.1

#### Safety Adapter
- **Rank (r)**: 8-16
- **Alpha**: 16-32
- **Target Modules**: q_proj, v_proj, k_proj, o_proj
- **Dropout**: 0.1

## Training Details

### Hyperparameters
- **Learning Rate**: 2e-4 to 5e-4
- **Batch Size**: 4-8 (with gradient accumulation: 4)
- **Epochs**: 3-5
- **Warmup Steps**: 100
- **Max Sequence Length**: 1024 tokens
- **Optimizer**: AdamW

### Training Infrastructure
- **Framework**: HuggingFace Transformers + PEFT
- **Quantization**: Optional 4-bit/8-bit for memory efficiency
- **Hardware**: GPU recommended (CUDA-capable)

## Evaluation

### Safety Evaluation
- **Metric**: 100% avoidance of diagnostic terms in test set
- **Forbidden Terms**: "diagnose", "diagnosis", "treat", "prescribe", "cure"
- **Result**: Model avoids diagnostic language, enforced by safety adapter and post-processing filter

### Medical Accuracy
- **Metric**: Coherence with rule engine outputs (>90% target)
- **Evaluation**: Summary quality matches rule engine acuity and emergency flags
- **Question Relevance**: Generated questions are relevant to symptom presentations

### Performance Metrics
- **Inference Latency**: Target <2 seconds per request
- **Memory Usage**: Configurable via quantization (4-bit/8-bit)
- **Throughput**: Varies by hardware configuration

## Limitations

### Known Limitations
1. **No Direct Diagnosis**: Model explicitly avoids diagnostic language. All outputs are advisory.
2. **Requires Clinician Review**: All model outputs must be reviewed by licensed clinicians before use.
3. **Training Data Dependency**: Model quality depends on training data quality and diversity.
4. **Language**: Currently optimized for English language medical triage.
5. **Context Window**: Limited to 1024 tokens for generation tasks.

### Potential Biases
- Training data may reflect biases in source medical scenarios
- Model outputs should be validated for cultural sensitivity
- Age, gender, and demographic factors in training data may influence outputs

## Ethical Considerations

### Medical Safety
- **Non-Diagnostic**: Model explicitly avoids diagnostic claims
- **Clinician Oversight**: All outputs require clinician review
- **Advisory Only**: Model provides suggestions, not medical decisions

### Data Privacy
- **No PHI Storage**: Model does not store patient health information
- **De-Identified Training**: Training data must be de-identified
- **Audit Logging**: All model invocations are logged for compliance

## Mitigation Strategies

1. **Safety Filter**: Post-processing safety filter removes any diagnostic terms that might slip through
2. **Rule Engine First**: Deterministic rule engine runs before AI summarization
3. **Audit Trail**: All model versions and outputs are logged for compliance
4. **Version Control**: Model versions tracked in audit logs for traceability

## Model Versioning

- **Versioning Scheme**: `llama-lora-safe-{major}.{minor}` for medical adapter
- **Safety Adapter**: `safety-adapter-v{major}` for safety adapter
- **Metadata**: Model metadata stored in `model_metadata.json` and `adapter_metadata.json`

## Usage Instructions

### Loading the Model
```python
from ml_model_service import get_model_service

service = get_model_service()
service.load_model()
```

### Generating Summaries
```python
summary = service.generate_clinician_summary(
    rule_result={"acuity": "Emergent", "emergencyFlag": True, "rationale": "..."},
    symptoms=["chest pain", "shortness of breath"],
)
```

### Generating Questions
```python
questions = service.generate_clarifying_questions(
    symptoms=["chest pain", "shortness of breath"],
)
```

## Citation

If you use this model, please cite:
- Base Model: Llama 2/3 (Meta AI)
- Framework: HuggingFace Transformers, PEFT
- This Model: Medical Insights Triage Assistant

## Contact

For questions or issues related to this model, refer to the project documentation or contact the development team.

## License

Model usage is subject to the project's license terms. Base Llama models are subject to their respective licenses from Meta AI.
