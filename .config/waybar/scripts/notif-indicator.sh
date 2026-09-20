#!/usr/bin/env bash
if swaync-client -D 2>/dev/null | grep -q "true"; then
    echo '{"text":"󰂛","tooltip":"Notifications silenced","class":"active"}'
else
    echo '{"text":"󰂚","tooltip":"Notifications active","class":"inactive"}'
fi
