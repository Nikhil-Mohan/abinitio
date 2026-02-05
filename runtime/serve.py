#!/usr/bin/env python3
"""Simple HTTP server that serves index.html on / requests."""
import http.server
import socketserver
import sys
from pathlib import Path

PORT = 8080

# Look for public/ in CWD first (where master_pipeline.sh runs from),
# then relative to script location as fallback
PUBLIC_DIR = Path("public")
if not PUBLIC_DIR.exists():
    PUBLIC_DIR = Path(__file__).parent.parent / "public"

class IndexHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler that serves index.html for / requests."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(PUBLIC_DIR), **kwargs)
    
    def translate_path(self, path):
        """Serve index.html when / is requested."""
        if path == "/":
            path = "/index.html"
        return super().translate_path(path)
    
    def log_message(self, format, *args):
        """Log HTTP requests."""
        print(f"[HTTP] {format % args}", flush=True)

if __name__ == "__main__":
    print(f"[SERVER] Looking for public directory: {PUBLIC_DIR}", flush=True)
    
    if not PUBLIC_DIR.exists():
        print(f"[ERROR] Public directory does not exist: {PUBLIC_DIR}", flush=True)
        sys.exit(1)
    
    try:
        with socketserver.TCPServer(("", PORT), IndexHTTPRequestHandler) as httpd:
            print(f"[SERVER] Serving HTTP on port {PORT}", flush=True)
            print(f"[SERVER] Serving from: {PUBLIC_DIR.resolve()}", flush=True)
            httpd.serve_forever()
    except Exception as e:
        print(f"[ERROR] {e}", flush=True)
        sys.exit(1)


