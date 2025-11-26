#!/bin/bash

# Iconos (Nerd Fonts) - Infalibles
ICON_VOL=" "
ICON_VOL_MUTE=" "
ICON_BRI=" "
ICON_CAPS=" "

# Función para notificar con barra de progreso
notify_osd() {
    local value=$1
    local icon=$2
    local type=$3
    local stack_tag="osd_${type}"
    
    # Solo mostramos Icono + Porcentaje
    notify-send -u low -t 1500 \
        -h string:x-dunst-stack-tag:$stack_tag \
        -h int:value:$value \
        "$icon $value%"
}

# Función para notificar estado (Texto simple)
notify_text() {
    local text=$1
    local icon=$2
    local type=$3
    local stack_tag="osd_${type}"
    
    notify-send -u low -t 1500 \
        -h string:x-dunst-stack-tag:$stack_tag \
        "$icon $text"
}

case $1 in
    vol_up)
        pamixer -i 5
        vol=$(pamixer --get-volume)
        notify_osd "$vol" "$ICON_VOL" "audio"
        ;;
    vol_down)
        pamixer -d 5
        vol=$(pamixer --get-volume)
        notify_osd "$vol" "$ICON_VOL" "audio"
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
            notify_text "Silenciado" "$ICON_VOL_MUTE" "audio"
        else
            vol=$(pamixer --get-volume)
            notify_osd "$vol" "$ICON_VOL" "audio"
        fi
        ;;
    bri_up)
        brightnessctl set +5%
        max=$(brightnessctl m)
        current=$(brightnessctl g)
        percent=$(( 100 * current / max ))
        notify_osd "$percent" "$ICON_BRI" "video"
        ;;
    bri_down)
        brightnessctl set 5%-
        max=$(brightnessctl m)
        current=$(brightnessctl g)
        percent=$(( 100 * current / max ))
        notify_osd "$percent" "$ICON_BRI" "video"
        ;;
    caps_lock)
        sleep 0.1
        # Intento 1: Buscar archivo en /sys/class/leds
        CAPS_FILE=$(find /sys/class/leds -name "*capslock*" | grep "brightness" | head -n 1)
        
        # Intento 2: Si falla, buscar input generico (a veces pasa en VMs)
        if [ -z "$CAPS_FILE" ]; then
             CAPS_FILE=$(find /sys/class/leds -name "input*::capslock" | grep "brightness" | head -n 1)
        fi

        if [ -n "$CAPS_FILE" ]; then
            STATUS=$(cat "$CAPS_FILE")
            if [ "$STATUS" == "1" ]; then
                notify_text "MAYÚSCULAS: ACTIVO" "$ICON_CAPS" "caps"
            else
                notify_text "MAYÚSCULAS: Inactivo" "$ICON_CAPS" "caps"
            fi
        else
            # Fallback si no hay LED accesible
            notify_text "Bloq Mayús (Sin Estado)" "$ICON_CAPS" "caps"
        fi
        ;;
esac
