"""
Medical Accuracy Evaluation Tests
Tests to validate summary quality, question relevance, and clinical appropriateness
"""

import pytest
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from app import (
    _summarise_for_clinician_fallback,
    _clarifying_questions_fallback,
)
from ml_model_service import ML_MODEL_AVAILABLE, get_model_service


class MockSymptomPayload:
    """Mock symptom payload for testing"""
    def __init__(self, symptoms, freeText=None):
        self.symptoms = symptoms
        self.freeText = freeText


def test_summary_includes_acuity():
    """Test that clinician summary includes acuity level"""
    rule_result = {
        "acuity": "Emergent",
        "emergencyFlag": True,
        "rationale": "Chest pain with breathing difficulty",
    }
    symptoms = MockSymptomPayload(["chest pain", "shortness of breath"])
    
    summary = _summarise_for_clinician_fallback(rule_result, symptoms)
    
    assert "Emergent" in summary or "emergency" in summary.lower(), \
        "Summary should include acuity level"


def test_summary_includes_emergency_flag():
    """Test that summary includes emergency flag information"""
    rule_result = {
        "acuity": "Emergent",
        "emergencyFlag": True,
        "rationale": "Chest pain with breathing difficulty",
    }
    symptoms = MockSymptomPayload(["chest pain", "shortness of breath"])
    
    summary = _summarise_for_clinician_fallback(rule_result, symptoms)
    
    assert "emergency" in summary.lower() or "true" in summary.lower(), \
        "Summary should indicate emergency flag"


def test_summary_includes_key_symptoms():
    """Test that summary includes key symptoms"""
    rule_result = {
        "acuity": "Urgent",
        "emergencyFlag": False,
        "rationale": "Fever with cough",
    }
    symptoms = MockSymptomPayload(["fever", "cough", "sore throat"])
    
    summary = _summarise_for_clinician_fallback(rule_result, symptoms)
    
    # Should include at least one symptom
    assert any(symptom in summary.lower() for symptom in ["fever", "cough", "throat"]), \
        "Summary should include key symptoms"


def test_summary_includes_rationale():
    """Test that summary includes rationale from rule engine"""
    rule_result = {
        "acuity": "Routine",
        "emergencyFlag": False,
        "rationale": "No red flags detected; clinician review still required",
    }
    symptoms = MockSymptomPayload(["headache"])
    
    summary = _summarise_for_clinician_fallback(rule_result, symptoms)
    
    assert "rationale" in summary.lower() or "red flags" in summary.lower(), \
        "Summary should include rationale"


def test_clarifying_questions_are_relevant():
    """Test that clarifying questions are relevant to symptoms"""
    # Test with chest pain - should get chest pain specific question
    symptoms = MockSymptomPayload(["chest pain", "shortness of breath"])
    questions = _clarifying_questions_fallback(symptoms)
    
    assert len(questions) > 0, "Should generate at least one question"
    
    # Check for chest pain specific question
    chest_pain_questions = [q for q in questions if "chest" in q.lower() or "pain" in q.lower()]
    assert len(chest_pain_questions) > 0, \
        "Should generate chest pain specific questions"


def test_clarifying_questions_format():
    """Test that clarifying questions are properly formatted"""
    symptoms = MockSymptomPayload(["fever", "cough"])
    questions = _clarifying_questions_fallback(symptoms)
    
    assert isinstance(questions, list), "Questions should be a list"
    assert len(questions) > 0, "Should generate at least one question"
    
    for question in questions:
        assert isinstance(question, str), "Each question should be a string"
        assert len(question.strip()) > 0, "Questions should not be empty"
        assert question.endswith("?") or any(qword in question.lower() for qword in ["when", "any", "how"]), \
            f"Question '{question}' should be a proper question"


def test_summary_coherence_with_rule_engine():
    """Test that summary is coherent with rule engine outputs"""
    test_cases = [
        {
            "rule_result": {
                "acuity": "Emergent",
                "emergencyFlag": True,
                "rationale": "Chest pain with breathing difficulty",
            },
            "symptoms": ["chest pain", "shortness of breath"],
            "expected_acuity": "Emergent",
        },
        {
            "rule_result": {
                "acuity": "Urgent",
                "emergencyFlag": False,
                "rationale": "Fever with cough",
            },
            "symptoms": ["fever", "cough"],
            "expected_acuity": "Urgent",
        },
        {
            "rule_result": {
                "acuity": "Routine",
                "emergencyFlag": False,
                "rationale": "No red flags detected",
            },
            "symptoms": ["headache"],
            "expected_acuity": "Routine",
        },
    ]
    
    for test_case in test_cases:
        symptoms = MockSymptomPayload(test_case["symptoms"])
        summary = _summarise_for_clinician_fallback(test_case["rule_result"], symptoms)
        
        # Summary should reflect the acuity level
        assert test_case["expected_acuity"].lower() in summary.lower(), \
            f"Summary should reflect acuity '{test_case['expected_acuity']}'"


def test_empty_symptoms_handling():
    """Test handling of empty symptoms list"""
    rule_result = {
        "acuity": "Unknown",
        "emergencyFlag": False,
        "rationale": "No symptoms provided",
    }
    symptoms = MockSymptomPayload([])
    
    summary = _summarise_for_clinician_fallback(rule_result, symptoms)
    
    # Should still generate a summary
    assert len(summary) > 0, "Should generate summary even with empty symptoms"
    assert "not a diagnosis" in summary.lower(), "Should include disclaimer"


@pytest.mark.skipif(not ML_MODEL_AVAILABLE, reason="ML model not available")
def test_ml_model_summary_quality():
    """Test ML model generates high-quality summaries"""
    # This test would require the model to be loaded
    service = get_model_service()
    
    if service.is_loaded():
        rule_result = {
            "acuity": "Urgent",
            "emergencyFlag": False,
            "rationale": "Fever with cough",
        }
        symptoms = ["fever", "cough"]
        
        summary = service.generate_clinician_summary(
            rule_result=rule_result,
            symptoms=symptoms,
        )
        
        # Check summary quality
        assert len(summary) > 50, "Summary should be substantial"
        assert "fever" in summary.lower() or "cough" in summary.lower(), \
            "Summary should mention symptoms"
        assert "not a diagnosis" in summary.lower() or "advisory" in summary.lower(), \
            "Summary should include safety disclaimer"


@pytest.mark.skipif(not ML_MODEL_AVAILABLE, reason="ML model not available")
def test_ml_model_questions_relevance():
    """Test ML model generates relevant clarifying questions"""
    service = get_model_service()
    
    if service.is_loaded():
        questions = service.generate_clarifying_questions(
            symptoms=["chest pain", "shortness of breath"],
        )
        
        assert len(questions) > 0, "Should generate at least one question"
        assert len(questions) <= 5, "Should limit to 5 questions"
        
        for question in questions:
            assert isinstance(question, str), "Each question should be a string"
            assert len(question.strip()) > 0, "Questions should not be empty"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
