#!/usr/bin/env bash
# list-apps.sh — outputs JSON array of {name, exec, icon} for app launcher
python3 - << 'PYEOF'
import json
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gio, Gtk

apps = []
icon_theme = Gtk.IconTheme.get_default()
try:
    icon_theme.set_custom_theme("Fluent")
except Exception:
    pass

for app in Gio.AppInfo.get_all():
    try:
        if not app.should_show():
            continue
        name = app.get_display_name()
        exec_cmd = app.get_commandline() or app.get_executable() or ""
        for code in ["%f", "%F", "%u", "%U", "%i", "%c", "%k"]:
            exec_cmd = exec_cmd.replace(code, "")
        exec_cmd = exec_cmd.strip()
        if not exec_cmd:
            continue

        icon_path = ""
        icon = app.get_icon()
        if icon:
            names = []
            if hasattr(icon, "get_names"):
                names = icon.get_names() or []
            elif hasattr(icon, "to_string"):
                names = [icon.to_string()]
            for n in names:
                if n.startswith("/"):
                    icon_path = n
                    break
                info = icon_theme.lookup_icon(n, 48, 0)
                if info:
                    icon_path = info.get_filename()
                    break

        apps.append({"name": name, "exec": exec_cmd, "icon": icon_path or ""})
    except Exception:
        continue

# Dedupe by name, sort
seen = set()
unique = []
for a in sorted(apps, key=lambda x: x["name"].lower()):
    if a["name"] not in seen:
        seen.add(a["name"])
        unique.append(a)

print(json.dumps(unique))
PYEOF
