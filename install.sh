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

# --- Kitty ---
echo -e "\nConfigurando Kitty..."
create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"

# --- Fuentes ---
install_fonts() {
    echo -e "\n${BLUE}Verificando fuentes...${NC}"
    FONT_PKG="ttf-jetbrains-mono-nerd"
    
    if command -v pacman &> /dev/null; then
        if ! pacman -Qi $FONT_PKG &> /dev/null; then
            echo -e "${BLUE}Instalando $FONT_PKG... (requiere sudo)${NC}"
            sudo pacman -S --noconfirm $FONT_PKG
            echo -e "${GREEN}Fuente instalada correctamente.${NC}"
        else
            echo -e "${BLUE}$FONT_PKG ya está instalada.${NC}"
        fi
    else
        echo -e "${BLUE}No se detectó pacman. Por favor instala 'JetBrainsMono Nerd Font' manualmente.${NC}"
    fi
}

install_fonts

echo -e "${GREEN}Instalación completada.${NC}"
