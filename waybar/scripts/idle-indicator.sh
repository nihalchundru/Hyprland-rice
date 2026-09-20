#!/usr/bin/env bash
if pgrep hypridle > /dev/null 2>&1; then
    echo '{"text":"","tooltip":"Idle enabled","class":"active"}'
else
    echo '{"text":"󰒲","tooltip":"Idle disabled","class":"inactive"}'
fi
