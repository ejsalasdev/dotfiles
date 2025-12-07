#!/bin/bash

# Función para obtener el estado de una batería
get_battery_info() {
    local battery_path="$1"
    local name="$2"

    # Verificar si el dispositivo de batería existe
    if ! upower -i "$battery_path" &> /dev/null; then
        echo "$name: No detectado"
        return
    fi

    local percentage=$(upower -i "$battery_path" | grep "percentage" | awk '{print $2}')
    local state=$(upower -i "$battery_path" | grep "state" | awk '{print $2}')
    local time_to_empty=$(upower -i "$battery_path" | grep "time to empty" | awk '{print $4, $5}')
    local time_to_full=$(upower -i "$battery_path" | grep "time to full" | awk '{print $4, $5}')

    local info="$name: $percentage ($state)"

    if [ "$state" = "discharging" ] && [ -n "$time_to_empty" ]; then
        info="$info, ~ $time_to_empty restantes"
    elif [ "$state" = "charging" ] && [ -n "$time_to_full" ]; then
        info="$info, ~ $time_to_full para cargar"
    elif [ "$state" = "fully-charged" ]; then
        info="$info, completamente cargado"
    fi
    echo "$info"
}

# Obtener información de la batería del laptop
LAPTOP_BATTERY_PATH="/org/freedesktop/UPower/devices/battery_BAT0"
LAPTOP_INFO=$(get_battery_info "$LAPTOP_BATTERY_PATH" "Laptop")

# Obtener información de la batería del teclado
KEYBOARD_BATTERY_PATH="/org/freedesktop/UPower/devices/battery_hidpp_battery_0"
KEYBOARD_INFO=$(get_battery_info "$KEYBOARD_BATTERY_PATH" "Teclado")

# Imprimir el tooltip
echo -e "$LAPTOP_INFO\n$KEYBOARD_INFO"
