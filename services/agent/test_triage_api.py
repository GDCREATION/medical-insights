"""
Test script for Triage API
Tests the /triage endpoint with sample data
"""

import requests
import json
import sys

# API endpoint
BASE_URL = "http://localhost:8000"

def test_health():
    """Test health endpoint"""
    print("=" * 60)
    print("Testing Health Endpoint")
    print("=" * 60)
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200
    except requests.exceptions.ConnectionError:
        print("ERROR: Cannot connect to service. Is it running on port 8000?")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

def test_triage(symptoms, free_text=None, trace_id=None):
    """Test triage endpoint"""
    print("\n" + "=" * 60)
    print("Testing Triage Endpoint")
    print("=" * 60)
    
    payload = {
        "encounterRef": "test-enc-001",
        "symptoms": {
            "symptoms": symptoms,
            "freeText": free_text
        }
    }
    
    headers = {"Content-Type": "application/json"}
    if trace_id:
        headers["X-Trace-Id"] = trace_id
    
    print(f"\nRequest:")
    print(json.dumps(payload, indent=2))
    
    try:
        response = requests.post(
            f"{BASE_URL}/triage",
            json=payload,
            headers=headers,
            timeout=30
        )
        
        print(f"\nStatus Code: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            print(f"\nResponse:")
            print(json.dumps(result, indent=2))
            
            # Print key information
            print("\n" + "-" * 60)
            print("Key Information:")
            print("-" * 60)
            print(f"Acuity: {result.get('acuity')}")
            print(f"Emergency Flag: {result.get('emergencyFlag')}")
            print(f"Model Version: {result.get('modelVersion')}")
            print(f"Adapter Version: {result.get('adapterVersion')}")
            print(f"\nSummary for Clinician:")
            print(result.get('summaryForClinician', '')[:200] + "...")
            print(f"\nClarifying Questions ({len(result.get('clarifyingQuestions', []))}):")
            for i, q in enumerate(result.get('clarifyingQuestions', [])[:3], 1):
                print(f"  {i}. {q}")
            return True
        else:
            print(f"ERROR: {response.status_code}")
            print(response.text)
            return False
            
    except requests.exceptions.ConnectionError:
        print("ERROR: Cannot connect to service. Is it running on port 8000?")
        return False
    except Exception as e:
        print(f"ERROR: {e}")
        return False

def main():
    """Run all tests"""
    print("\n" + "=" * 60)
    print("TRIAGE API TEST SUITE")
    print("=" * 60)
    
    # Test 1: Health check
    if not test_health():
        print("\n[ERROR] Health check failed. Please start the service first.")
        print("\nTo start the service:")
        print("  cd services/agent")
        print("  python -m uvicorn app:app --host 0.0.0.0 --port 8000")
        sys.exit(1)
    
    # Test 2: Emergency case - chest pain
    print("\n\n" + "=" * 60)
    print("TEST 1: Emergency Case - Chest Pain")
    print("=" * 60)
    test_triage(
        symptoms=["chest pain", "shortness of breath"],
        free_text="Started 30 minutes ago, getting worse",
        trace_id="test-trace-emergency"
    )
    
    # Test 3: Urgent case - fever and cough
    print("\n\n" + "=" * 60)
    print("TEST 2: Urgent Case - Fever and Cough")
    print("=" * 60)
    test_triage(
        symptoms=["fever", "cough", "sore throat"],
        free_text="Started 2 days ago, temperature 101°F",
        trace_id="test-trace-urgent"
    )
    
    # Test 4: Routine case
    print("\n\n" + "=" * 60)
    print("TEST 3: Routine Case - Headache")
    print("=" * 60)
    test_triage(
        symptoms=["headache", "mild nausea"],
        free_text="Started this morning, not severe",
        trace_id="test-trace-routine"
    )
    
    print("\n\n" + "=" * 60)
    print("TESTING COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nTest interrupted by user")
    except Exception as e:
        print(f"\n\nERROR: {e}")
        import traceback
        traceback.print_exc()
