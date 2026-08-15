import websocket
import json
import ssl

def test_cc():
    ws = websocket.create_connection("wss://pubsub.crowdcontrol.live/", sslopt={"cert_reqs": ssl.CERT_NONE})
    print("Connected")
    ws.send(json.dumps({"action": "whoami"}))
    msg = ws.recv()
    print("whoami response:", msg)
    
    # Try logging in via WS?
    ws.send(json.dumps({
        "action": "login",
        "applicationID": "ccaid-01kmnsgfktb4gswz5ffa42tqtk",
        "secret": "089ae51ac5b1ab8975eea2c4f4576385376477a0a3623877a08b8b9e2bc82a8f",
        "gameID": "BlaziumDemo"
    }))
    msg = ws.recv()
    print("login response:", msg)

test_cc()
