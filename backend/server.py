#!/usr/bin/env python3
"""Server praktikum tanpa dependensi: API laporan + simpan gambar base64.
Jalankan: python backend/server.py (laptop dan emulator harus satu jaringan).
Bukan untuk penggunaan produksi: tanpa autentikasi atau HTTPS.
"""
import base64
import binascii
import json
import os
import uuid
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

BASE = Path(__file__).resolve().parent
STORE = Path(os.environ.get('CAMPUS_REPORT_DATA_DIR', str(BASE / 'data')))
STORE.mkdir(exist_ok=True)
DB = STORE / 'reports.json'

def records():
    if DB.exists():
        return json.loads(DB.read_text(encoding='utf-8'))
    return []

def save(rows):
    DB.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')

class Handler(BaseHTTPRequestHandler):
    def reply(self, status, obj):
        payload = json.dumps(obj).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        if self.path == '/health':
            return self.reply(200, {'ok': True})
        if self.path == '/reports':
            return self.reply(200, {'reports': records()})
        return self.reply(404, {'error': 'Not found'})

    def do_POST(self):
        if self.path != '/reports':
            return self.reply(404, {'error': 'Not found'})
        try:
            size = int(self.headers.get('Content-Length', '0'))
            if size <= 0 or size > 8 * 1024 * 1024:
                return self.reply(413, {'error': 'Payload kosong/terlalu besar'})
            data = json.loads(self.rfile.read(size).decode('utf-8'))
            key = data.get('clientReportId', '')
            if not key or not isinstance(key, str):
                return self.reply(400, {'error': 'clientReportId wajib'})
            if not data.get('title') or not data.get('description'):
                return self.reply(400, {'error': 'title & description wajib'})
            current = records()
            for row in current:
                if row['clientReportId'] == key:
                    return self.reply(200, {'serverId': row['serverId'], 'duplicate': True})
            photo = data.pop('photoBase64', None)
            data['serverId'] = str(uuid.uuid4())
            if photo:
                content = base64.b64decode(photo, validate=True)
                if len(content) > 5 * 1024 * 1024:
                    return self.reply(413, {'error': 'Foto melebihi 5 MB'})
                name = data['serverId'] + '.jpg'
                (STORE / name).write_bytes(content)
                data['photoFile'] = name
            current.append(data)
            save(current)
            return self.reply(201, {'serverId': data['serverId'], 'duplicate': False})
        except (ValueError, UnicodeError, KeyError, TypeError, binascii.Error) as exc:
            return self.reply(400, {'error': str(exc)})

if __name__ == '__main__':
    port = int(os.environ.get('CAMPUS_REPORT_PORT', '8000'))
    print(f'Mock API: http://0.0.0.0:{port}, /health, /reports')
    HTTPServer(('0.0.0.0', port), Handler).serve_forever()
