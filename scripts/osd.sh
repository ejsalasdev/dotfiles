#!/bin/bash

# Iconos
# Usamos Unicode estándar para evitar problemas de renderizado de Nerd Fonts específicos
ICON_VOL="🔊"
ICON_VOL_MUTE="🔇"
ICON_BRI="🔆"
ICON_CAPS="Aa" 

# Función para notificar con barra de progreso
notify_osd() {
    local value=$1
    local icon=$2
    local type=$3
    local stack_tag="osd_${type}"
    
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
            notify_text "SILENCIADO" "$ICON_VOL_MUTE" "audio"
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
        # Intentar leer el estado usando brightnessctl (busca dispositivos tipo 'leds')
        # El patrón '*::capslock' busca cualquier dispositivo que termine en capslock
        STATUS=$(brightnessctl --class=leds --device='*::capslock' get 2>/dev/null)

        if [ "$STATUS" == "1" ]; then
            notify_text "MAYÚSCULAS: ACTIVO" "$ICON_CAPS" "caps"
        elif [ "$STATUS" == "0" ]; then
            notify_text "MAYÚSCULAS: Inactivo" "$ICON_CAPS" "caps"
        else
            # Si falla brightnessctl, intentamos fallback manual
            sleep 0.1
            CAPS_FILE=$(find /sys/class/leds -name "*capslock*" | grep "brightness" | head -n 1)
            if [ -n "$CAPS_FILE" ]; then
                 VAL=$(cat "$CAPS_FILE")
                 if [ "$VAL" == "1" ]; then
                    notify_text "MAYÚSCULAS: ACTIVO" "$ICON_CAPS" "caps"
                 else
                    notify_text "MAYÚSCULAS: Inactivo" "$ICON_CAPS" "caps"
                 fi
            else
                 notify_text "Bloq Mayús (No detectado)" "$ICON_CAPS" "caps"
            fi
        fi
        ;;
esac
