#!/bin/bash
# Obtén la lista de monitores
monitors=$(hyprctl monitors -j | jq -r '.[] | "\(.description)|\(.width)x\(.height)"')

# Configura basado en resolución (ejemplo: 1920x1080 para monitores pequeños, 2560x1440 para grandes)
while IFS='|' read -r desc res; do
    if [[ "$res" == "1920x1080" ]]; then
        hyprctl keyword monitor "desc:$desc,1920x1080@144,0x300,1"
    elif [[ "$res" == "2560x1440" ]]; then
        hyprctl keyword monitor "desc:$desc,2560x1440@180,1920x0,1"
    fi
done <<< "$monitors"