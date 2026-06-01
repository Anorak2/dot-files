#!/usr/bin/env bash

used_pct=$(top -bn1 | awk '/^%Cpu/ { printf "%d", $2 + $4 }')

if [ "$used_pct" -lt 20 ]; then
  pie="○"
elif [ "$used_pct" -lt 40 ]; then
  pie="◔"
elif [ "$used_pct" -lt 60 ]; then
  pie="◑"
elif [ "$used_pct" -lt 80 ]; then
  pie="◕"
else
  pie="●"
fi

printf '{"text":"%s %s%%","tooltip":"CPU usage: %s%%"}\n' "$pie" "$used_pct" "$used_pct"
