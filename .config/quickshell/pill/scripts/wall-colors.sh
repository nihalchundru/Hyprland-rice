#!/usr/bin/env bash
# For every wallpaper the picker would list, print:  <path><TAB><RRGGBB RRGGBB ...>
# (a 12x12 sample of the image). Results are cached by path + modification time,
# so only new or changed wallpapers are read after the first run.
# Needs ImageMagick (magick or convert); without it this prints nothing and the
# picker simply has no colour filter.
im=$(command -v magick || command -v convert) || exit 0      # no ImageMagick: say nothing

here="$(cd "$(dirname "$0")" && pwd)"
cache="$HOME/.cache/quickshell/pill/wall-colors.tsv"

mkdir -p "$(dirname "$cache")" && touch "$cache"

declare -A known
while IFS=$'\t' read -r mt p px; do
    [ -n "$px" ] && known["$mt|$p"]="$px"
done < "$cache"

bash "$here/wall-list.sh" | while IFS= read -r f; do
    mt=$(stat -c %Y "$f" 2>/dev/null) || continue
    px="${known["$mt|$f"]}"
    if [ -z "$px" ]; then
        px=$("$im" "$f[0]" -define jpeg:size=64x64 -resize 12x12! -alpha off -depth 8 txt:- 2>/dev/null \
             | grep -oE '#[0-9A-Fa-f]{6}' | tr -d '#' | tr '\n' ' ')
        [ -n "$px" ] && printf '%s\t%s\t%s\n' "$mt" "$f" "$px" >> "$cache"
    fi
    [ -n "$px" ] && printf '%s\t%s\n' "$f" "$px"
done
exit 0
