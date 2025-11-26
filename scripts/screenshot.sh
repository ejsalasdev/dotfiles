#!/bin/bash

DIR="$HOME/Imágenes/Capturas de pantalla"
NAME="Captura desde $(date +'%Y-%m-%d %H-%M-%S').png"
FILE="$DIR/$NAME"

# Asegurar que el directorio existe
mkdir -p "$DIR"

if [ "$1" == "region" ]; then
    # Capturar región, guardar y copiar
    grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" && notify-send -i "camera-photo" "Captura Guardada" "$NAME"
else
    # Capturar todo, guardar y copiar
    grim "$FILE" && wl-copy < "$FILE" && notify-send -i "camera-photo" "Captura Guardada" "$NAME"
fi
