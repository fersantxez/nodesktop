#!/usr/bin/env python3
"""Open an audio/video fixture in a disposable desktop and verify its sound."""
import asyncio
import os
import struct
import sys
from aiohttp import BasicAuth, ClientSession, TCPConnector, WSMsgType

port = os.environ.get('VNC_PORT', '6901')
base = f'https://127.0.0.1:{port}'
password = os.environ.get('NODESKTOP_TEST_PASSWORD') or os.environ.get('VNC_PW')
if not password:
    with open(os.environ.get('VNC_PASSWORD_FILE', '/run/secrets/vnc_password'), encoding='utf-8') as secret:
        password = secret.readline().rstrip('\r\n')
os.environ.setdefault('DISPLAY', os.environ.get('VNC_DISPLAY', ':1'))
os.environ.setdefault('XDG_CURRENT_DESKTOP', 'XFCE')

async def main():
    async with ClientSession(connector=TCPConnector(ssl=False)) as session:
        async with session.ws_connect(base + '/nodesktop/audio', headers={'Origin': base}, auth=BasicAuth(os.environ.get('VNC_USER', 'nodesktop'), password)) as ws:
            proc = await asyncio.create_subprocess_exec('xdg-open', sys.argv[1])
            await proc.wait()
            assert proc.returncode == 0
            peak = 0
            for _ in range(400):
                message = await asyncio.wait_for(ws.receive(), 5)
                assert message.type == WSMsgType.BINARY
                peak = max(peak, max(abs(sample[0]) for sample in struct.iter_unpack('<h', message.data)))
                if peak > 500:
                    break
            assert peak > 500, peak
            print('PASS: multimedia file produced audio on the authenticated stream')

asyncio.run(main())
