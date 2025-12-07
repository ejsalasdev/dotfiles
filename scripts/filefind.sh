#!/bin/bash

# Este script utiliza fd y wofi para buscar archivos y directorios, y abrirlos.

# Buscar archivos y directorios en el HOME, excluyendo .git, .cache y .local/share
# y usando 'fd' para velocidad
SEARCH_RESULTS=$(fd --max-depth 5 --type f --type d --hidden --exclude ".git" --exclude ".cache" --exclude ".local/share" . "$HOME" | wofi --show dmenu --width 600 --height 400 --prompt "Buscar Archivo..." --cache-file /dev/null)

# Abrir el archivo/directorio seleccionado
if [ -n "$SEARCH_RESULTS" ]; then
    xdg-open "$SEARCH_RESULTS" &
fi
