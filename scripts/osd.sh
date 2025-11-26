#!/bin/bash

# Iconos
ICON_VOL=" "
ICON_VOL_MUTE=" "
ICON_BRI=" "
ICON_CAPS=" "

# Función común para notificar
# Uso: notify_osd "valor" "icono" "tipo(audio/video/caps)"
notify_osd() {
    local value=$1
    local icon=$2
    local type=$3
    
    # Tag para sobrescribir la notificación anterior
    local stack_tag="osd_${type}"

    # -t 1500: Duración de 1.5 segundos
    # -h int:value:$value: Barra de progreso
    notify-send -u low -t 1500 -h string:x-dunst-stack-tag:$stack_tag -h int:value:$value "$icon $value%"
}

# Función simple para texto (sin barra)
notify_text() {
    local text=$1
    local type=$2
    local stack_tag="osd_${type}"
    notify-send -u low -t 1500 -h string:x-dunst-stack-tag:$stack_tag "$text"
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
        pamixer -t
        muted=$(pamixer --get-mute)
        if [ "$muted" == "true" ]; then
            notify_text "$ICON_VOL_MUTE Silenciado" "audio"
        else
            vol=$(pamixer --get-volume)
            notify_osd "$vol" "$ICON_VOL" "audio"
        fi
        ;;
    bri_up)
        brightnessctl set +5%
        max=$(brightnessctl m)
        current=$(brightnessctl g)
        # Calculamos porcentaje entero
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
        # Esperamos un milisegundo para que el LED cambie de estado
        sleep 0.1
        # Buscamos el archivo del LED de CapsLock (puede variar según hardware)
        CAPS_FILE=$(find /sys/class/leds -name "*capslock*" | grep "brightness" | head -n 1)
        
        if [ -n "$CAPS_FILE" ]; then
            STATUS=$(cat "$CAPS_FILE")
            if [ "$STATUS" == "1" ]; then
                notify_text "$ICON_CAPS MAYÚSCULAS: ACTIVADO" "caps"
            else
                notify_text "$ICON_CAPS MAYÚSCULAS: Desactivado" "caps"
            fi
        else
            notify_text "No se detectó LED de CapsLock" "caps"
        fi
        ;;
esac
