#!/bin/bash

# Opciones con iconos (Nerd Fonts)
SHUTDOWN=" Apagar"
REBOOT=" Reiniciar"
SUSPEND=" Suspender"
LOCK=" Bloquear"
LOGOUT=" Cerrar Sesión"

# Mostrar menú con Wofi
# Ajustamos ancho y alto para que parezca un menú emergente compacto
CHOICE=$(echo -e "$LOCK\n$SUSPEND\n$LOGOUT\n$REBOOT\n$SHUTDOWN" | wofi --show dmenu --width 200 --height 250 --prompt "Menú de Energía" --cache-file /dev/null)

case "$CHOICE" in
    "$SHUTDOWN")
        systemctl poweroff
        ;;
    "$REBOOT")
        systemctl reboot
        ;;
    "$SUSPEND")
        systemctl suspend
        ;;
    "$LOCK")
        pidof hyprlock || hyprlock
        ;;
    "$LOGOUT")
        loginctl terminate-user $USER
        ;;
esac
