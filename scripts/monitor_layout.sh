#!/bin/bash

# Reiniciar todas las configuraciones de monitor
# Opcional: Deshabilitar todos los monitores para un lienzo limpio y evitar conflictos
# hyprctl output disable "*"
# sleep 0.1 # Dar un respiro a Hyprland

# Contar monitores conectados
CONNECTED_MONITORS=$(hyprctl monitors -j | jq '. | length')
MAIN_MONITOR="eDP-1" # Monitor de la laptop (integrado)
EXTERNAL_MONITOR="HDMI-A-1" # Monitor externo

# === Configuración de un solo monitor (Solo Laptop) ===
if [ "$CONNECTED_MONITORS" -eq 1 ]; then
    echo "Detectado un solo monitor: $MAIN_MONITOR"
    # Configurar el monitor principal (laptop) a 0x0
    hyprctl keyword monitor "$MAIN_MONITOR, preferred, 0x0, 1"
    
    # Asegurarse de que el monitor externo no tenga una configuración residual
    hyprctl keyword monitor "$EXTERNAL_MONITOR, disable" # Deshabilitar explícitamente el externo

    # Asignar todos los workspaces al monitor principal (eDP-1)
    for i in {1..10}; do
        hyprctl keyword workspace "$i, monitor:$MAIN_MONITOR"
    done

# === Configuración de doble monitor ===
elif [ "$CONNECTED_MONITORS" -eq 2 ]; then
    echo "Detectados dos monitores: $EXTERNAL_MONITOR (externo) y $MAIN_MONITOR (laptop)"
    
    # Configurar monitor externo (izquierda, primario)
    hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, 0x0, 1"
    # Configurar monitor principal (derecha del externo)
    hyprctl keyword monitor "$MAIN_MONITOR, preferred, 1920x0, 1"

    # Asignar workspaces
    # HDMI-A-1 (Externo): Workspaces 1-5
    for i in {1..5}; do
        hyprctl keyword workspace "$i, monitor:$EXTERNAL_MONITOR"
    done
    # eDP-1 (Laptop): Workspaces 6-10
    for i in {6..10}; do
        hyprctl keyword workspace "$i, monitor:$MAIN_MONITOR"
    done

    # Después de configurar, enfocar el monitor externo para que muestre su W1
    hyprctl dispatch focusmonitor "$EXTERNAL_MONITOR"
fi

# Recargar Waybar para que se adapte al nuevo layout de monitores
# Usamos un pequeño delay para asegurar que Hyprland haya aplicado los cambios
sleep 0.5
killall waybar && waybar &

echo "Configuración de monitores aplicada."
