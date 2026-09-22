#!/usr/bin/env bash
if [ "$1" = "--current-icon" ]; then
    COND=$(curl -sf --max-time 5 "wttr.in/?format=%C" 2>/dev/null | tr '[:upper:]' '[:lower:]')
    case "$COND" in
        *sunny*|*clear*)     echo "" ;;
        *cloud*|*overcast*)  echo "" ;;
        *rain*|*drizzle*)    echo "󰖗" ;;
        *snow*)              echo "" ;;
        *thunder*|*storm*)   echo "" ;;
        *fog*|*mist*)        echo "󰖑" ;;
        *)                   echo "" ;;
    esac
elif [ "$1" = "--current-temp" ]; then
    TEMP=$(curl -sf --max-time 5 "wttr.in/?format=%t" 2>/dev/null | tr -d '+')
    echo "${TEMP:-~°C}"
fi
