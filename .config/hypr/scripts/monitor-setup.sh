#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-dual}"  # dual | primary | secondary
RETRY_ATTEMPTS=3
RETRY_DELAY=0.5

PRIMARY="ViewSonic Corporation VX2728-QHD X2F241580010"
SECONDARY="ViewSonic Corporation XG2405 W9Q210302159"

if [[ "$MODE" == "--help" || "$MODE" == "-h" ]]; then
    echo "Uso: $0 [dual|primary|secondary]"
    exit 0
fi

# Función para ejecutar comando con reintentos
execute_with_retry() {
    local cmd="$1"
    local attempt=1

    while (( attempt <= RETRY_ATTEMPTS )); do
        if eval "$cmd" 2>/dev/null; then
            return 0
        fi
        if (( attempt < RETRY_ATTEMPTS )); then
            sleep "$RETRY_DELAY"
        fi
        ((attempt++))
    done

    echo "❌ Error ejecutando: $cmd" >&2
    return 1
}

# Obtener monitores actualmente activos
mapfile -t CONNECTED < <(
    hyprctl monitors -j | jq -r '.[].description'
)

# Verifica si un monitor está en la lista de objetivo (para no apagarlo después)
is_target() {
    local target="$1"
    shift
    for m in "$@"; do
        [[ "$m" == "$target" ]] && return 0
    done
    return 1
}

configure_monitor() {
    local desc="$1"
    local config="$2"
    if execute_with_retry "hyprctl keyword monitor \"desc:$desc,$config\""; then
        echo "✓ $desc configurado ($config)"
        return 0
    else
        echo "⚠️  No se pudo configurar $desc (¿conectado?)"
        return 1
    fi
}

disable_monitor_if_present() {
    local desc="$1"
    for m in "${CONNECTED[@]}"; do
        if [[ "$m" == "$desc" ]]; then
            execute_with_retry "hyprctl keyword monitor \"desc:$desc,disable\""
            echo "⏻ $desc desactivado"
            return 0
        fi
    done
    return 0
}

case "$MODE" in
    dual)
        echo "🖥️  Configurando modo dual..."
        configure_monitor "$PRIMARY" "2560x1440@180,1920x0,1"
        configure_monitor "$SECONDARY" "1920x1080@144,0x300,1"
        TARGET_MONITORS=($PRIMARY $SECONDARY)
        ;;

    primary)
        echo "🖥️  Configurando modo primario..."
        configure_monitor "$PRIMARY" "2560x1440@180,0x0,1" || exit 1
        TARGET_MONITORS=($PRIMARY)
        disable_monitor_if_present "$SECONDARY"
        ;;

    secondary)
        echo "🖥️  Configurando modo secundario..."
        configure_monitor "$SECONDARY" "1920x1080@144,0x0,1" || exit 1
        TARGET_MONITORS=($SECONDARY)
        disable_monitor_if_present "$PRIMARY"
        ;;

    *)
        echo "❌ Modo inválido: $MODE"
        echo "Usa: dual | primary | secondary"
        exit 1
        ;;
esac

# Apaga monitores que no formen parte de los objetivos actuales
mapfile -t POST_ACTIVE < <(
    hyprctl monitors -j | jq -r '.[].description'
)

for m in "${POST_ACTIVE[@]}"; do
    if ! is_target "$m" "${TARGET_MONITORS[@]}"; then
        execute_with_retry "hyprctl keyword monitor \"desc:$m,disable\""
        echo "⏻ $m desactivado"
    fi
done

echo "✅ Configuración completada"

