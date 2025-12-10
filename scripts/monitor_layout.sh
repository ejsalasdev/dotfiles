#!/bin/bash

# --- CONFIGURACIÓN ---
MAIN_MONITOR="eDP-1"       # Laptop
EXTERNAL_MONITOR="HDMI-A-1" # Externo

# Función para mover workspaces a un monitor específico
move_workspaces() {
    local monitor=$1
    local start=$2
    local end=$3

    for ((i=start; i<=end; i++)); do
        # 1. Asignar la regla para el futuro
        hyprctl keyword workspace "$i, monitor:$monitor"
        # 2. Mover forzosamente el workspace si ya existe (corrige el problema del WS 1)
        hyprctl dispatch moveworkspacetomonitor "$i $monitor"
    done
}

# --- DETECCIÓN ---
# Contar monitores conectados
CONNECTED_MONITORS=$(hyprctl monitors -j | jq '. | length')

if [ "$CONNECTED_MONITORS" -eq 1 ]; then
    echo "--- Modo Laptop (1 Monitor) ---"
    # Configurar monitor
    hyprctl keyword monitor "$MAIN_MONITOR, preferred, 0x0, 1"
    
    # Mover TODOS los workspaces (1-10) a la laptop
    move_workspaces "$MAIN_MONITOR" 1 10

elif [ "$CONNECTED_MONITORS" -ge 2 ]; then
    echo "--- Modo Escritorio (2+ Monitores) ---"
    # Configurar posiciones
    hyprctl keyword monitor "$EXTERNAL_MONITOR, preferred, 0x0, 1"
    hyprctl keyword monitor "$MAIN_MONITOR, preferred, 1920x0, 1"

    # Mover Workspaces 1-5 al Externo (¡Forzando el movimiento!)
    move_workspaces "$EXTERNAL_MONITOR" 1 5
    
    # Mover Workspaces 6-10 a la Laptop
    move_workspaces "$MAIN_MONITOR" 6 10
    
    # Enfocar el workspace 1 en el monitor principal para empezar bien
    hyprctl dispatch focusmonitor "$EXTERNAL_MONITOR"
    hyprctl dispatch workspace 1
fi

# Recargar Waybar para actualizar módulos
sleep 1
killall waybar && waybar &
echo "Layout aplicado correctamente."