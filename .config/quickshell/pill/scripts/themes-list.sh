#!/usr/bin/env bash
# Prints one line per theme found in themes.sh:
# name|BG|TEXT|ACCENT|ACCENT2|GREEN|YELLOW|RED|TEAL
f="$HOME/.config/hypr/themes/themes.sh"
[ -f "$f" ] || exit 0
for t in $(grep -oE '^ {4}[A-Za-z0-9_-]+\)' "$f" | tr -d ' )'); do
    (
        source "$f" "$t" >/dev/null 2>&1
        printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
            "$t" "$BG" "$TEXT" "$ACCENT" "$ACCENT2" "$GREEN" "$YELLOW" "$RED" "$TEAL"
    )
done
