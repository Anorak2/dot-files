#!/usr/bin/env bash

used_pct=$(top -bn1 | awk '/^%Cpu/ { printf "%d", $2 + $4 }')

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

printf '{"text":"%s %s%%","tooltip":"CPU usage: %s%%"}\n' "$pie" "$used_pct" "$used_pct"

