#!/bin/bash

# Verificar conexión
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "{\"text\": \"\", \"tooltip\": \"Offline\"}"
    exit 0
fi

# Obtener datos
TEXT=$(curl -s "https://wttr.in/?format=%c%20%t")
TOOLTIP=$(curl -s "https://wttr.in/?format=%C+%t+\nSensación:+%f\nHumedad:+%h\nViento:+%w")

if [ -n "$TEXT" ]; then
    # Usar jq para crear JSON válido
    jq -n --arg text "$TEXT" --arg tooltip "$TOOLTIP" \
        '{text: $text, tooltip: $tooltip, class: "weather"}'
else
    echo "{\"text\": \"...\", \"tooltip\": \"Cargando...\"}"
fi