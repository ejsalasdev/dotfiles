#!/bin/bash

# Iconos
ICON_VOL=" "
ICON_VOL_MUTE=" "
ICON_BRI=" "

# Función para notificar
notify_osd() {
    local value=$1
    local icon=$2
    local type=$3
    
    # ID de pila para que se sobrescriba
    local stack_tag="osd_${type}"

    # Enviar notificación a Dunst
    # -u low: Urgencia baja
    # -h string:x-dunst-stack-tag:... : La clave para que se reemplace
    # -h int:value:... : El valor para la barra de progreso
    notify-send -u low -h string:x-dunst-stack-tag:$stack_tag -h int:value:$value "$icon $value%"
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
            notify-send -u low -h string:x-dunst-stack-tag:osd_audio "$ICON_VOL_MUTE Silenciado"
        else
            vol=$(pamixer --get-volume)
            notify_osd "$vol" "$ICON_VOL" "audio"
        fi
        ;;
    bri_up)
        brightnessctl set +5%
        # Obtener porcentaje actual (truco con awk porque brightnessctl da valor absoluto a veces)
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
esac
