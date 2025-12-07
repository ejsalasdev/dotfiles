#!/bin/bash

# Script simple para obtener clima de wttr.in
# Intenta detectar ubicación por IP. Puedes forzar ciudad con: wttr.in/Bogota

# Icono y Temperatura
TEXT=$(curl -s "https://wttr.in/?format=%c+%t")

# Tooltip con más detalles
# %C: Condición, %t: Temp, %f: Sensación, %h: Humedad, %w: Viento
TOOLTIP=$(curl -s "https://wttr.in/?format=%C\nTemp: %t\nSensación: %f\nHumedad: %h\nViento: %w")

if [ -n "$TEXT" ]; then
    # Limpiar y formatear tooltip para JSON (escapar saltos de línea y comillas)
    # Usamos python para el escape JSON seguro si está disponible, o sed
    if command -v python3 &> /dev/null; then
        json_tooltip=$(python3 -c "import json, sys; print(json.dumps(sys.stdin.read().strip()))" <<< "$TOOLTIP")
        # python devuelve las comillas alrededor, las quitamos para meterlo en nuestra estructura o usamos jq
        # Mejor aun, construimos todo el json con jq si está disponible (ya lo instalamos)
    fi
    
    if command -v jq &> /dev/null; then
        jq -n --arg text "$TEXT" --arg tooltip "$TOOLTIP" '{text: $text, tooltip: $tooltip, class: "weather"}'
    else
        # Fallback manual (menos robusto)
        ESCAPED_TOOLTIP=$(echo "$TOOLTIP" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
        echo "{\"text\": \"$TEXT\", \"tooltip\": \"$ESCAPED_TOOLTIP\", \"class\": \"weather\"}"
    fi
else
    echo "{\"text\": \"\", \"tooltip\": \"Offline\"}"
fi
