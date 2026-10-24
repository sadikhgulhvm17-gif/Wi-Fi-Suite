import json
from http.server import BaseHTTPRequestHandler, HTTPServer

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({"ok": True}).encode())

    def do_POST(self):
        if self.path == '/analyze':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length)
            data = json.loads(body)
            rssi = data.get("rssi", -70)
            quality = max(0, min(100, 100 + rssi))
            response = {"quality": quality, "status": "good" if quality > 50 else "poor"}
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps(response).encode())

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8082), Handler)
    print("Python Analytics Server running on port 8082")
    server.serve_forever()
