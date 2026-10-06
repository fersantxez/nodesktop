#!/usr/bin/env python3
"""Read-only Xvnc CPU sample; run inside the container during a known workload.

Usage: docker exec -i CONTAINER python3 - [SECONDS] < tests/xvnc-cpu.py
Percent is normalized to one CPU core. This measures Xvnc, not extraction jobs.
"""
import json
import os
from pathlib import Path
import sys
import time

seconds = float(sys.argv[1]) if len(sys.argv) > 1 else 15.0
if not 1 <= seconds <= 60:
    raise SystemExit("Sample duration must be between 1 and 60 seconds")
servers = []
for comm in Path("/proc").glob("[0-9]*/comm"):
    try:
        if comm.read_text().strip() == "Xvnc":
            servers.append(comm.parent)
    except FileNotFoundError:
        continue
if len(servers) != 1:
    raise SystemExit(f"Expected one Xvnc process, found {len(servers)}")
process = servers[0]


def sample():
    fields = (process / "stat").read_text().rsplit(") ", 1)[1].split()
    return int(fields[19]), int(fields[11]) + int(fields[12])


identity, before = sample()
started = time.monotonic()
time.sleep(seconds)
after_identity, after = sample()
elapsed = time.monotonic() - started
if identity != after_identity:
    raise SystemExit("Xvnc restarted during sampling")
print(json.dumps({
    "pid": int(process.name),
    "seconds": round(elapsed, 3),
    "cpu_percent_one_core": round(100 * (after - before) / os.sysconf("SC_CLK_TCK") / elapsed, 2),
}))
