#!/usr/bin/env python3
"""Authenticated same-origin audio and reverse proxy for KasmVNC."""
import argparse
import asyncio
import ssl
from urllib.parse import urlsplit
from aiohttp import ClientSession, ClientTimeout, WSMsgType, web

HOP = {'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization',
       'te', 'trailers', 'transfer-encoding', 'upgrade', 'host', 'content-length'}

async def audio(request):
    origin = request.headers.get('Origin', '')
    parsed = urlsplit(origin)
    if parsed.scheme != 'https' or parsed.netloc.lower() != request.host.lower():
        raise web.HTTPForbidden()
    auth = request.headers.get('Authorization')
    if not auth:
        raise web.HTTPUnauthorized(headers={'WWW-Authenticate': 'Basic realm="KasmVNC"'})
    async with request.app['client'].get(request.app['backend'] + '/index.html', headers={'Authorization': auth}) as check:
        if check.status != 200:
            raise web.HTTPUnauthorized(headers={'WWW-Authenticate': 'Basic realm="KasmVNC"'})
    ws = web.WebSocketResponse(heartbeat=20, max_msg_size=4096)
    await ws.prepare(request)
    proc = await asyncio.create_subprocess_exec('parec', '--device=nodesktop.monitor', '--format=s16le', '--rate=48000', '--channels=2', '--latency-msec=60', stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.DEVNULL)
    async def send():
        try:
            while True:
                data = await proc.stdout.readexactly(3840)
                await asyncio.wait_for(ws.send_bytes(data), timeout=2)
        except (asyncio.IncompleteReadError, asyncio.TimeoutError, ConnectionError):
            await ws.close()
    task = asyncio.create_task(send())
    try:
        async for msg in ws:
            if msg.type in (WSMsgType.ERROR, WSMsgType.CLOSE):
                break
    finally:
        task.cancel()
        if proc.returncode is None:
            try:
                proc.terminate()
            except ProcessLookupError:
                pass
        try:
            await asyncio.wait_for(proc.wait(), 2)
        except asyncio.TimeoutError:
            proc.kill()
            await proc.wait()
        await asyncio.gather(task, return_exceptions=True)
    return ws

async def proxy(request):
    target = request.app['backend'] + request.rel_url.raw_path_qs
    headers = {k: v for k, v in request.headers.items() if k.lower() not in HOP and not k.lower().startswith('sec-websocket-')}
    if request.headers.get('Upgrade', '').lower() == 'websocket':
        try:
            upstream = await request.app['client'].ws_connect(target, headers=headers, protocols=request.headers.get('Sec-WebSocket-Protocol', '').split(',') if request.headers.get('Sec-WebSocket-Protocol') else ())
        except Exception:
            raise web.HTTPBadGateway()
        ws = web.WebSocketResponse(protocols=[upstream.protocol] if upstream.protocol else ())
        await ws.prepare(request)
        async def forward(src, dst):
            async for m in src:
                if m.type == WSMsgType.BINARY: await dst.send_bytes(m.data)
                elif m.type == WSMsgType.TEXT: await dst.send_str(m.data)
                elif m.type in (WSMsgType.CLOSE, WSMsgType.ERROR): break
            await dst.close()
        await asyncio.gather(forward(ws, upstream), forward(upstream, ws))
        return ws
    async with request.app['client'].request(request.method, target, headers=headers, data=await request.read(), allow_redirects=False) as upstream:
        response = web.StreamResponse(status=upstream.status, headers={k:v for k,v in upstream.headers.items() if k.lower() not in HOP and k.lower() != 'content-encoding'})
        await response.prepare(request)
        async for chunk in upstream.content.iter_chunked(65536): await response.write(chunk)
        return response

async def start(app):
    connector = __import__('aiohttp').TCPConnector(ssl=False)
    app['client'] = ClientSession(connector=connector, timeout=ClientTimeout(total=None), auto_decompress=True)
async def stop(app):
    await app['client'].close()

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--port', type=int, required=True)
    p.add_argument('--backend', type=int, required=True)
    p.add_argument('--cert', required=True)
    p.add_argument('--key', required=True)
    args=p.parse_args()
    app=web.Application(client_max_size=16*1024*1024)
    app['backend']=f'https://127.0.0.1:{args.backend}'
    app.on_startup.append(start); app.on_cleanup.append(stop)
    app.router.add_get('/nodesktop/audio', audio)
    app.router.add_route('*', '/{path:.*}', proxy)
    ctx=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER); ctx.load_cert_chain(args.cert,args.key)
    web.run_app(app, host='127.0.0.1', port=args.port, ssl_context=ctx, access_log=None)
if __name__ == '__main__': main()
