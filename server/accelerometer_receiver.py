import websocket
import json
import socket
import time



def on_message(ws, message):
    values = json.loads(message)['values']
    x = values[0]
    y = values[1]
    z = values[2]
    print("x = ", x , "y = ", y , "z = ", z )
    
    # Conecta e envia para o Godot
    send_to_godot(x, y, z)
    
def send_to_godot(x, y, z):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        # Conecta ao Godot (localhost, porta 9080)
        s.connect(('localhost', 9080))
            
        # Prepara os dados no formato JSON
        data = json.dumps({
            'x': x,
            'y': y,
            'z': z,
            'timestamp': time.time()
        })
            
        # Envia os dados
        s.sendall(data.encode('utf-8'))

def on_error(ws, error):
    print("error occurred ", error)
    
def on_close(ws, close_code, reason):
    print("connection closed : ", reason)
    
def on_open(ws):
    print("connected")
    

def connect(url):
    ws = websocket.WebSocketApp(url,
                              on_open=on_open,
                              on_message=on_message,
                              on_error=on_error,
                              on_close=on_close)

    ws.run_forever()
 
 
connect("ws://192.168.15.75:8080/sensor/connect?type=android.sensor.accelerometer") 

