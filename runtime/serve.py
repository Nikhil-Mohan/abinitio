#!/usr/bin/env python3
"""Simple HTTP server that serves index.html on / requests."""
import http.server
import socketserver
import sys
import os
from pathlib import Path

PORT = 8080
PUBLIC_DIR = Path("public")

class IndexHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler that serves index.html for / requests."""
    
    def translate_path(self, path):
        """Serve index.html when / is requested."""
        if path == "/":
            path = "/index.html"
        return super().translate_path(path)
    
    def log_message(self, format, *args):
        """Log HTTP requests."""
        print(f"[HTTP] {format % args}", flush=True)

if __name__ == "__main__":
    os.chdir(PUBLIC_DIR)
    
    with socketserver.TCPServer(("", PORT), IndexHTTPRequestHandler) as httpd:
        print(f"[SERVER] Serving HTTP on port {PORT}", flush=True)
        print(f"[SERVER] Serving files from: {PUBLIC_DIR.resolve()}", flush=True)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[SERVER] Shutting down", flush=True)
            sys.exit(0)
