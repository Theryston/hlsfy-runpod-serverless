import runpod
import os
import requests
from dotenv import load_dotenv
import time

load_dotenv()

def handler(event):
    HLSFY_API_HOST = os.getenv("HLSFY_API_HOST")
    
    if not HLSFY_API_HOST:
        raise ValueError("[RUNPOD] HLSFY_API_HOST is not set")
    
    input = event['input']
    
    if input.get('check_only'):
        response = requests.get(f"{HLSFY_API_HOST}")
        return response.json()

    response = requests.post(f"{HLSFY_API_HOST}", json=input)
    data = response.json()
    
    status = data['status']
    
    while status != 'done' and status != 'failed':
        print(f"[RUNPOD] Status: {status} - waiting for new status")
        time.sleep(1)
        data = requests.get(f"{HLSFY_API_HOST}/{data['id']}").json()
        status = data['status']

    return data

if __name__ == '__main__':
    runpod.serverless.start({'handler': handler })