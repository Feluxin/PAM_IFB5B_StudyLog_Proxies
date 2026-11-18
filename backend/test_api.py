import json
import os
import tempfile
import subprocess
import sys
import time
import unittest
from urllib.request import Request, urlopen
from pathlib import Path

BACKEND = Path(__file__).with_name('server.py')

class ApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tempdir = tempfile.TemporaryDirectory()
        env = {**os.environ, 'CAMPUS_REPORT_PORT': '8001',
               'CAMPUS_REPORT_DATA_DIR': cls.tempdir.name}
        cls.proc = subprocess.Popen([sys.executable, str(BACKEND)], env=env,
                                    stdout=subprocess.DEVNULL,
                                    stderr=subprocess.DEVNULL)
        time.sleep(1.5)
    @classmethod
    def tearDownClass(cls):
        cls.proc.terminate()
        cls.proc.wait(timeout=5)
        cls.tempdir.cleanup()
    def test_idempotency(self):
        content = json.dumps({'clientReportId':'api-smoke-id-001', 'title':'Lampu padam',
                              'description':'Lampu lab komputer padam'}).encode()
        req = lambda: Request('http://127.0.0.1:8001/reports',
                              data=content, headers={'Content-Type':'application/json'})
        with urlopen(req()) as r: a=json.loads(r.read())
        with urlopen(req()) as r: b=json.loads(r.read())
        self.assertEqual(a['serverId'], b['serverId'])
        self.assertTrue(b['duplicate'])

if __name__ == '__main__': unittest.main()
