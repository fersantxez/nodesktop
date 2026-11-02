#!/usr/bin/env python3
"""Run inside a Nodesktop container against its TLS listener."""
import asyncio
import math
import os
import struct
from aiohttp import BasicAuth, ClientSession, TCPConnector, WSMsgType

PORT = int(os.environ.get('VNC_PORT', '6901'))
BASE = f'https://127.0.0.1:{PORT}'
password = os.environ.get('NODESKTOP_TEST_PASSWORD') or os.environ.get('VNC_PW')
if not password:
    with open(os.environ.get('VNC_PASSWORD_FILE', '/run/secrets/vnc_password'), encoding='utf-8') as secret:
        password = secret.readline().rstrip('\r\n')
AUTH = BasicAuth(os.environ.get('VNC_USER', 'nodesktop'), password)

async def main():
    async with ClientSession(connector=TCPConnector(ssl=False)) as session:
        async with session.get(BASE + '/index.html') as response:
            assert response.status == 401, response.status
        async with session.get(BASE + '/index.html', auth=AUTH) as response:
            assert response.status == 200, response.status
            assert 'nodesktop-audio.js' in await response.text()
        async with session.get(BASE + '/nodesktop/audio', headers={'Origin': 'https://attacker.invalid'}, auth=AUTH) as response:
            assert response.status == 403, response.status
        async with session.get(BASE + '/nodesktop/audio', headers={'Origin': BASE}) as response:
            assert response.status == 401, response.status
        async with session.get(BASE + '/nodesktop/audio', headers={'Origin': BASE}, auth=BasicAuth(AUTH.login, 'wrong-password')) as response:
            assert response.status == 401, response.status
        async with session.ws_connect(BASE + '/nodesktop/audio', headers={'Origin': BASE}, auth=AUTH) as ws:
            proc = await asyncio.create_subprocess_exec('paplay', '--raw', '--rate=48000', '--channels=2', '--format=s16le', stdin=asyncio.subprocess.PIPE)
            tone = b''.join(struct.pack('<hh', value, value) for value in (int(14000 * math.sin(2 * math.pi * 440 * i / 48000)) for i in range(48000 * 2)))
            proc.stdin.write(tone)
            await proc.stdin.drain()
            proc.stdin.close()
            peak = 0
            for _ in range(200):
                msg = await asyncio.wait_for(ws.receive(), timeout=5)
                assert msg.type == WSMsgType.BINARY, msg.type
                peak = max(peak, max(abs(v) for (v,) in struct.iter_unpack('<h', msg.data)))
                if peak > 1000:
                    break
            await proc.wait()
            assert proc.returncode == 0 and peak > 1000, (proc.returncode, peak)
    print('PASS: TLS, authentication, origin isolation, and audible PCM over WebSocket')

asyncio.run(main())
