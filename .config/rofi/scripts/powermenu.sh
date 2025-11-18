#!/bin/bash

# Opciones del menú principal
shutdown=" Shutdown"
reboot=" Reboot"
lock=" Lock"
logout=" Logout"
options="$shutdown\n$reboot\n$lock\n$logout"

# Función de confirmación
confirm_action() {
    local action_name=$1
    local confirm_prompt="Are you sure you want to ${action_name}?"
    
    # Mostrar el menú de confirmación de Rofi
    local confirmed=$(echo -e "Yes\nNo" | rofi -dmenu -i -p "$confirm_prompt" -config "~/.config/rofi/confirm.rasi")

    if [ "$confirmed" == "Yes" ]; then
        case "$action_name" in
            "shutdown")
                systemctl poweroff
                ;;
            "reboot")
                systemctl reboot
                ;;
            "logout")
                i3-msg exit
                ;;
        esac
    fi
}

# Mostrar el menú principal de Rofi
selected_option=$(echo -e "$options" | rofi -dmenu -i -p "System" -config "~/.config/rofi/powermenu.rasi")

# Ejecutar la acción seleccionada
case "$selected_option" in
    "$shutdown")
        confirm_action "shutdown"
        ;;
    "$reboot")
        confirm_action "reboot"
        ;;
    "$lock")
        i3lock
        ;;
    "$logout")
        confirm_action "logout"
        ;;
esac
