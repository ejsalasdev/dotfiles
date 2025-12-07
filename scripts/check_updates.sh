#!/bin/bash

# Contar actualizaciones oficiales
OFFICIAL=$(checkupdates | wc -l)

# Contar actualizaciones AUR (si yay está instalado)
if command -v yay &> /dev/null; then
    AUR=$(yay -Qua | wc -l)
else
    AUR=0
fi

TOTAL=$((OFFICIAL + AUR))

# Generar JSON para Waybar
if [ "$TOTAL" -gt 0 ]; then
    TOOLTIP="Oficiales: $OFFICIAL\nAUR: $AUR"
    echo "{\"text\": \" $TOTAL\", \"tooltip\": \"$TOOLTIP\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"\", \"tooltip\": \"Sistema actualizado\", \"class\": \"none\"}"
fi
