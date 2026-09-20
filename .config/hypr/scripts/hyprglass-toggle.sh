#!/bin/bash

STATUS=$(hyprpm list | awk '
/Plugin hyprglass/ {
    found=1
}
found && /enabled:/ {
    print $2
    exit
}
')

if [ "$STATUS" = "true" ]; then
    hyprpm disable hyprglass
else
    hyprpm enable hyprglass
fi
