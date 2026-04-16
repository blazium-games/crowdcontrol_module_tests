import requests
import sys

app_id = "ccaid-01kmnsgfktb4gswz5ffa42tqtk"
secret = "089ae51ac5b1ab8975eea2c4f4576385376477a0a3623877a08b8b9e2bc82a8f"

endpoints = [
    "https://api.crowdcontrol.live/v1/oauth/token",
    "https://openapi.crowdcontrol.live/oauth/token",
    "https://openapi.crowdcontrol.live/auth",
    "https://auth.crowdcontrol.live/oauth/token",
    "https://pubsub.crowdcontrol.live/auth",
    "https://openapi.crowdcontrol.live/v2/oauth/token"
]

payloads = [
    {"grant_type": "client_credentials", "client_id": app_id, "client_secret": secret},
    {"applicationID": app_id, "secret": secret},
    {"appID": app_id, "secret": secret}
]

for url in endpoints:
    for p in payloads:
        try:
            r = requests.post(url, json=p, timeout=3)
            print(f"[{url}] JSON p={p}\n -> {r.status_code} {r.text[:100]}")
        except Exception as e:
            pass
        
        try:
            r = requests.post(url, data=p, timeout=3)
            print(f"[{url}] FORM p={p}\n -> {r.status_code} {r.text[:100]}")
        except Exception as e:
            pass
