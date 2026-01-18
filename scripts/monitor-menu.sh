#!/usr/bin/env bash
set -euo pipefail

# Simple frontend to pick monitor mode via dmenu/wofi/rofi
# Modes must match monitor-setup.sh options
MODES=(dual primary secondary)
SETUP_SCRIPT="$HOME/.local/bin/monitor-setup.sh"

if [[ ! -x "$SETUP_SCRIPT" ]]; then
    echo "monitor-setup.sh not found or not executable: $SETUP_SCRIPT" >&2
    exit 1
fi

# Detect current state to preselect/label
PRIMARY="ViewSonic Corporation VX2728-QHD X2F241580010"
SECONDARY="ViewSonic Corporation XG2405 W9Q210302159"

current_mode() {
    # Uses descriptions to decide; falls back to unknown
    local active
    mapfile -t active < <(hyprctl monitors -j | jq -r '.[] | select(.enabled==true) | .description')
    local has_p="0" has_s="0"
    for m in "${active[@]}"; do
        [[ "$m" == "$PRIMARY" ]] && has_p="1"
        [[ "$m" == "$SECONDARY" ]] && has_s="1"
    done
    if [[ "$has_p" == "1" && "$has_s" == "1" ]]; then
        echo "dual"
    elif [[ "$has_p" == "1" ]]; then
        echo "primary"
    elif [[ "$has_s" == "1" ]]; then
        echo "secondary"
    else
        echo "unknown"
    fi
}

menu_cmd() {
    if command -v rofi >/dev/null 2>&1; then
        echo "rofi -dmenu -p 'Monitor mode' -theme ~/.config/rofi/themes/appmnu.rasi"
    else
        echo "cat"  # last resort
    fi
}

MENU_CMD=$(menu_cmd)
CURRENT=$(current_mode)

# Build menu text with current mark
menu_items() {
    for m in "${MODES[@]}"; do
        if [[ "$m" == "$CURRENT" ]]; then
            echo "$m  (actual)"
        else
            echo "$m"
        fi
    done
}

CHOICE=$(menu_items | eval "$MENU_CMD")
CHOICE=${CHOICE%% *} # strip " (actual)"

if [[ -z "$CHOICE" ]]; then
    exit 0  # cancelled
fi

"$SETUP_SCRIPT" "$CHOICE" && notify-send "Monitores" "Modo: $CHOICE" 2>/dev/null || true
