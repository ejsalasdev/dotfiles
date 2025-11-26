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

# --- Wofi ---
echo -e "\nConfigurando Wofi..."
create_symlink "$DOTFILES_DIR/config/wofi" "$HOME/.config/wofi"

# --- Waybar ---
echo -e "\nConfigurando Waybar..."
create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"

# --- Paquetes y Fuentes ---
install_packages() {
    echo -e "\n${BLUE}Verificando paquetes necesarios...${NC}"
    
    if command -v pacman &> /dev/null; then
        # Lista de paquetes a verificar/instalar
        PACKAGES=(
            "ttf-jetbrains-mono-nerd" 
            "waybar" 
            "xdg-desktop-portal-hyprland" 
            "xdg-desktop-portal-gtk"
            "hyprpaper"
        )
        TO_INSTALL=()

        for pkg in "${PACKAGES[@]}"; do
            if ! pacman -Qi $pkg &> /dev/null; then
                TO_INSTALL+=("$pkg")
            else
                echo -e "${BLUE}$pkg ya está instalado.${NC}"
            fi
        done

        if [ ${#TO_INSTALL[@]} -gt 0 ]; then
            echo -e "${BLUE}Instalando: ${TO_INSTALL[*]}... (requiere sudo)${NC}"
            sudo pacman -S --noconfirm "${TO_INSTALL[@]}"
            echo -e "${GREEN}Paquetes instalados.${NC}"
        else
            echo -e "${GREEN}Todos los paquetes necesarios están instalados.${NC}"
        fi
    else
        echo -e "${BLUE}No se detectó pacman. Asegúrate de tener instalado: ${PACKAGES[*]}${NC}"
    fi
}

install_packages

echo -e "${GREEN}Instalación completada.${NC}"
