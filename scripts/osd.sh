#!/bin/bash

# --- Configuración ---
# Usamos iconos del sistema (Papirus-Dark) para mayor consistencia
ICO_VOL_HIGH="audio-volume-high"
ICO_VOL_LOW="audio-volume-low"
ICO_VOL_MUTE="audio-volume-muted"
ICO_BRI="display-brightness-symbolic"
ICO_CAPS="input-keyboard-symbolic"

# Función para notificar con barra de progreso
notify_osd() {
    local value=$1
    local icon=$2
    local type=$3
    local stack_tag="osd_${type}"
    
    notify-send -u low -t 1500 \
        -i "$icon" \
        -h string:x-dunst-stack-tag:$stack_tag \
        -h int:value:$value \
        "Ajuste de Nivel" "$value%"
}

# Función para notificar estado (Texto)
notify_state() {
    local text=$1
    local icon=$2
    local type=$3
    local stack_tag="osd_${type}"
    
    notify-send -u low -t 1500 \
        -i "$icon" \
        -h string:x-dunst-stack-tag:$stack_tag \
        "Estado" "$text"
}

case $1 in
    vol_up)
        pamixer -i 5
        vol=$(pamixer --get-volume)
        notify_osd "$vol" "$ICO_VOL_HIGH" "audio"
        ;;
    vol_down)
        pamixer -d 5
        vol=$(pamixer --get-volume)
        notify_osd "$vol" "$ICO_VOL_LOW" "audio"
        ;;
    vol_mute)
        # --- DEBOUNCE ---
        LOCK_FILE="/tmp/osd_vol_mute.last"
        NOW=$(date +%s%3N)
        if [ -f "$LOCK_FILE" ]; then
            LAST=$(cat "$LOCK_FILE")
            DIFF=$((NOW - LAST))
            [ $DIFF -lt 200 ] && exit 0
        fi
        echo $NOW > "$LOCK_FILE"
        # ----------------

        pamixer -t
        if pamixer --get-mute | grep -q "true"; then
            notify_state "Silenciado" "$ICO_VOL_MUTE" "audio"
        else
            vol=$(pamixer --get-volume)
            notify_osd "$vol" "$ICO_VOL_HIGH" "audio"
        fi
        ;;
    bri_up)
        brightnessctl set +5%
        max=$(brightnessctl m)
        current=$(brightnessctl g)
        percent=$(( 100 * current / max ))
        notify_osd "$percent" "$ICO_BRI" "video"
        ;;
    bri_down)
        brightnessctl set 5%-
        max=$(brightnessctl m)
        current=$(brightnessctl g)
        percent=$(( 100 * current / max ))
        notify_osd "$percent" "$ICO_BRI" "video"
        ;;
    caps_lock)
        # Esperar actualización del kernel
        sleep 0.1
        CAPS_FILE=$(find /sys/class/leds -name "*capslock*" | grep "brightness" | head -n 1)
        
        if [ -n "$CAPS_FILE" ]; then
            STATUS=$(cat "$CAPS_FILE")
            if [ "$STATUS" == "1" ]; then
                notify_state "MAYÚSCULAS: ACTIVO" "$ICO_CAPS" "caps"
            else
                notify_state "MAYÚSCULAS: Inactivo" "$ICO_CAPS" "caps"
            fi
        else
            # Fallback si no encuentra el LED
            notify_state "Cambio detectado" "$ICO_CAPS" "caps"
        fi
        ;;
esac
