#!/usr/bin/env bash
QS_CACHE_DIR="${HOME}/.cache/quickshell"
function qs_ensure_cache() {
    local name="$1"
    export QS_CACHE_WEATHER="${QS_CACHE_DIR}/${name}"
    mkdir -p "${QS_CACHE_WEATHER}"
}
