#!/usr/bin/env bash
FAVORITE="$HOME/Pictures/wallpapers/main-sky.jpeg"
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CUTOFF=25

get_wallpaper() {
  if [ $((RANDOM % 100)) -lt $CUTOFF ]; then
    echo "$FAVORITE"
  else
    find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" \) | shuf -n1
  fi
}

pkill swaybg
#[ "${1:-}" = "--startup" ] && sleep 2

wallpaper="$(get_wallpaper)"

while read -r output; do
  swaybg -o "$output" -i "$wallpaper" -m fill &
done < <(
  swaymsg -t get_outputs -r |
    jq -r '.[] | select(.active) | .name'
)
