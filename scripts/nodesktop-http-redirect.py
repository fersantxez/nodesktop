#!/usr/bin/env python3
"""Multiplex HTTP redirects and HTTPS KasmVNC on one public port.

KasmVNC's SSL-only listener intentionally resets plaintext connections.  The
desktop has historically been advertised as ``http://host:6901`` though, so a
small protocol-aware relay keeps that URL useful without exposing a second
service or weakening KasmVNC's TLS requirement:

* plaintext HTTP receives a 301 redirect to the same host/path over HTTPS;
* TLS records are passed through unchanged to KasmVNC's loopback backend.
"""

from __future__ import annotations

import argparse
import asyncio
import re
from collections.abc import Awaitable


TLS_RECORD_PREFIX = b"\x16\x03"
HOST_RE = re.compile(rb"(?:^|\r\n)Host:\s*([^\r\n]+)", re.IGNORECASE)
REQUEST_RE = re.compile(rb"^[A-Z]+\s+(\S+)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--listen", type=int, required=True)
    parser.add_argument("--backend", type=int, required=True)
    return parser.parse_args()


async def pipe(reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
    try:
        while chunk := await reader.read(64 * 1024):
            writer.write(chunk)
            await writer.drain()
    finally:
        if not writer.is_closing():
            writer.close()
            await writer.wait_closed()


async def redirect(writer: asyncio.StreamWriter, request: bytes) -> None:
    host_match = HOST_RE.search(request)
    request_match = REQUEST_RE.search(request)
    host = host_match.group(1).decode("latin-1", "replace").strip() if host_match else "localhost"
    path = request_match.group(1).decode("latin-1", "replace") if request_match else "/"
    location = f"https://{host}{path}"
    body = f"Redirecting to {location}\n".encode()
    response = (
        b"HTTP/1.1 301 Moved Permanently\r\n"
        + f"Location: {location}\r\n".encode()
        + b"Cache-Control: no-store\r\n"
        + b"Content-Type: text/plain; charset=utf-8\r\n"
        + f"Content-Length: {len(body)}\r\n".encode()
        + b"Connection: close\r\n\r\n"
        + body
    )
    writer.write(response)
    await writer.drain()


async def handle(
    reader: asyncio.StreamReader,
    writer: asyncio.StreamWriter,
    backend_port: int,
) -> None:
    try:
        prefix = await reader.read(8192)
        if not prefix:
            return
        if prefix.startswith(TLS_RECORD_PREFIX):
            try:
                backend_reader, backend_writer = await asyncio.open_connection("127.0.0.1", backend_port)
            except OSError:
                return
            backend_writer.write(prefix)
            await backend_writer.drain()
            await asyncio.gather(
                pipe(reader, backend_writer),
                pipe(backend_reader, writer),
            )
        else:
            await redirect(writer, prefix)
    finally:
        if not writer.is_closing():
            writer.close()
            await writer.wait_closed()


async def run(listen_port: int, backend_port: int) -> None:
    server = await asyncio.start_server(
        lambda reader, writer: handle(reader, writer, backend_port),
        "0.0.0.0",
        listen_port,
        limit=128 * 1024,
    )
    async with server:
        await server.serve_forever()


def main() -> None:
    args = parse_args()
    try:
        asyncio.run(run(args.listen, args.backend))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
