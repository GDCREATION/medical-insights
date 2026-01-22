import requests
import time

max_retries = 10
for i in range(max_retries):
    try:
        r = requests.get('http://localhost:8000/health', timeout=5)
        print(f'Agent Service Status: {r.status_code}')
        print('Response:', r.json())
        break
    except requests.exceptions.ConnectionError:
        print(f'Attempt {i+1}/{max_retries}: Service starting... (models may be loading)')
        if i < max_retries - 1:
            time.sleep(5)
    except Exception as e:
        print(f'Error: {e}')
        break
else:
    print('Service did not start within expected time. Check logs for errors.')
