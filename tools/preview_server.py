"""Serve the compiled Flutter demo locally. Python 3, no extra packages."""
from functools import partial
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import threading
import webbrowser

root = Path(__file__).resolve().parent.parent / 'preview'
if not (root / 'index.html').is_file():
    raise SystemExit('Preview missing. Extract the complete project ZIP first.')
handler = partial(SimpleHTTPRequestHandler, directory=str(root))
try:
    server = ThreadingHTTPServer(('127.0.0.1', 8765), handler)
except OSError:
    raise SystemExit('Port 8765 is busy. Close the other demo window and try again.')
url = 'http://127.0.0.1:8765'
print('ComQuiz: ' + url + '\nKeep this window open. Press Ctrl+C to stop.')
threading.Timer(0.7, lambda: webbrowser.open(url)).start()
try:
    server.serve_forever()
except KeyboardInterrupt:
    pass
finally:
    server.server_close()
