#!/bin/bash

# Este script utiliza wofi para buscar y seleccionar emojis, y wl-copy para copiarlo al portapapeles.

EMOJI_FILE="$HOME/.local/share/emojis.txt"

# Asegurarse de que el directorio de emojis exista
mkdir -p "$(dirname "$EMOJI_FILE")"

# Si el archivo de emojis no existe, lo creamos (esto puede tardar un poco la primera vez)
if [ ! -f "$EMOJI_FILE" ]; then
    notify-send "Emoji Picker" "Generando lista de emojis por primera vez..." -i face-smile
    # Descargar y procesar la lista de emojis desde GitHub
    curl -s "https://raw.githubusercontent.com/github/gemoji/master/db/emoji.json" | \
        jq -r '.[] | .emoji + " " + (.description // .aliases[0])' > "$EMOJI_FILE"
    notify-send "Emoji Picker" "Lista de emojis generada." -i face-smile
fi

# Lanzar wofi para seleccionar emoji
SELECTED_EMOJI=$(cat "$EMOJI_FILE" | wofi --show dmenu --width 400 --height 300 --prompt "Buscar Emoji..." --cache-file /dev/null | awk '{print $1}')

# Copiar al portapapeles si se seleccionó uno
if [ -n "$SELECTED_EMOJI" ]; then
    echo -n "$SELECTED_EMOJI" | wl-copy
    notify-send "Emoji Copiado" "$SELECTED_EMOJI" -i face-smile
fi
