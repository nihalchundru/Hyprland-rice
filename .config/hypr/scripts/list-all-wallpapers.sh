#!/usr/bin/env bash
# list-all-wallpapers.sh — lists ALL wallpapers from ALL theme folders
python3 - << 'PYEOF'
import json, os
from pathlib import Path

base = Path.home() / ".config/hypr/wallpapers"
files = []
for f in sorted(base.rglob("*")):
    if f.suffix.lower() in (".png", ".jpg", ".jpeg") and f.is_file():
        # Use theme/filename as display name
        rel = f.relative_to(base)
        name = str(rel.parent / f.stem).replace("/", " — ")
        files.append({"name": name, "path": str(f)})

print(json.dumps(files))
PYEOF
