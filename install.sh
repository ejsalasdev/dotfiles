#!/bin/bash

# Colores para logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Iniciando configuración de Dotfiles...${NC}"

# Directorio base de los dotfiles (donde está este script)
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Función para crear enlaces simbólicos
create_symlink() {
    local source=$1
    local target=$2

    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        # Es un enlace, verificamos si apunta a donde debe
        local current_target=$(readlink "$target")
        if [ "$current_target" == "$source" ]; then
             echo -e "${BLUE}Enlace correcto existente: $target${NC}"
        else
             echo -e "${BLUE}Actualizando enlace: $target -> $source${NC}"
             rm "$target"
             ln -s "$source" "$target"
        fi
    elif [ -e "$target" ]; then
        echo -e "${BLUE}Respaldando existente: $target -> $target.backup${NC}"
        mv "$target" "$target.backup"
        ln -s "$source" "$target"
        echo -e "${GREEN}Enlace creado: $target${NC}"
    else
        ln -s "$source" "$target"
        echo -e "${GREEN}Enlace creado: $target${NC}"
    fi
}

# --- Hyprland ---
echo -e "\nConfigurando Hyprland..."
create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"

echo -e "${GREEN}Instalación completada.${NC}"
