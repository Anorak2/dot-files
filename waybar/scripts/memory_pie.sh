#!/usr/bin/env bash

used_pct=$(free | awk '/Mem:/ { printf "%d", ($3/$2)*100 }')

if [ "$used_pct" -lt 13 ]; then
  pie="󰪞"
elif [ "$used_pct" -lt 26 ]; then
  pie="󰪟"
elif [ "$used_pct" -lt 39 ]; then
  pie="󰪠"
elif [ "$used_pct" -lt 52 ]; then
  pie="󰪡"
elif [ "$used_pct" -lt 65 ]; then
  pie="󰪢"
elif [ "$used_pct" -lt 78 ]; then
  pie="󰪣"
elif [ "$used_pct" -lt 91 ]; then
  pie="󰪤"
else
  pie="󰪥"
fi

printf '{"text":"%s %s%%","tooltip":"RAM usage: %s%%"}\n' "$pie" "$used_pct" "$used_pct"
