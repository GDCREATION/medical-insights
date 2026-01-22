"""
Prompt Templates for Medical Triage
Contains prompt templates for generating clinician summaries and clarifying questions
"""

from typing import Dict, Any, List, Optional


def format_clinician_summary_prompt(
    rule_result: Dict[str, Any],
    symptoms: List[str],
    free_text: Optional[str] = None,
) -> str:
    """Format prompt for generating clinician summary"""
    instruction = "Generate a non-diagnostic clinician summary for these symptoms and rule engine result."
    
    symptoms_str = ", ".join(symptoms) if symptoms else "No specific symptoms listed"
    input_text = f"Symptoms: {symptoms_str}"
    if free_text:
        input_text += f". Additional information: {free_text}"
    input_text += f". Acuity: {rule_result.get('acuity', 'unknown')}"
    input_text += f". Emergency: {rule_result.get('emergencyFlag', False)}"
    input_text += f". Rationale: {rule_result.get('rationale', '')}"
    
    prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
    return prompt


def format_clarifying_questions_prompt(
    symptoms: List[str],
    free_text: Optional[str] = None,
) -> str:
    """Format prompt for generating clarifying questions"""
    instruction = "Generate clarifying questions for these symptoms."
    
    symptoms_str = ", ".join(symptoms) if symptoms else "No specific symptoms listed"
    input_text = f"Symptoms: {symptoms_str}"
    if free_text:
        input_text += f". Additional information: {free_text}"
    
    prompt = f"### Instruction:\n{instruction}\n\n### Input:\n{input_text}\n\n### Response:\n"
    return prompt
