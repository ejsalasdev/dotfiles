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

# --- CONFIGURACIÓN (Symlinks) ---
echo -e "\n${BLUE}Creando enlaces simbólicos...${NC}"

# Hyprland
create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
# Kitty
create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
# Wofi
create_symlink "$DOTFILES_DIR/config/wofi" "$HOME/.config/wofi"
# Waybar
create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"
# GTK 3.0 (Tema oscuro)
create_symlink "$DOTFILES_DIR/config/gtk-3.0" "$HOME/.config/gtk-3.0"


# --- INSTALACIÓN DE PAQUETES ---
install_packages() {
    echo -e "\n${BLUE}Verificando paquetes necesarios...${NC}"
    
    if command -v pacman &> /dev/null; then
        
        # Categorías de paquetes
        CORE_PKGS=(
            "hyprland" "kitty" "waybar" "wofi" "hyprpaper" 
            "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
            "polkit-gnome" # Agente de autenticación ligero
        )
        
        FILE_MANAGER_PKGS=(
            "thunar" "thunar-volman" "thunar-archive-plugin" 
            "tumbler" "gvfs" "gvfs-mtp" "file-roller"
        )
        
        AUDIO_PKGS=(
            "pipewire" "pipewire-pulse" "wireplumber" "pavucontrol"
        )
        
        THEME_PKGS=(
            "gnome-themes-extra" "papirus-icon-theme" 
            "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji"
        )
        
        UTILS_PKGS=(
            "grim" "slurp" "wl-clipboard" "git" "curl"
        )

        # Unir todas las listas
        ALL_PACKAGES=("${CORE_PKGS[@]}" "${FILE_MANAGER_PKGS[@]}" "${AUDIO_PKGS[@]}" "${THEME_PKGS[@]}" "${UTILS_PKGS[@]}")
        TO_INSTALL=()

        echo -e "${BLUE}Comprobando ${#ALL_PACKAGES[@]} paquetes...${NC}"

        for pkg in "${ALL_PACKAGES[@]}"; do
            if ! pacman -Qi $pkg &> /dev/null; then
                TO_INSTALL+=("$pkg")
            fi
        done

        if [ ${#TO_INSTALL[@]} -gt 0 ]; then
            echo -e "${BLUE}Instalando paquetes faltantes: ${TO_INSTALL[*]}${NC}"
            # Usamos sudo para instalar
            sudo pacman -S --noconfirm --needed "${TO_INSTALL[@]}"
            echo -e "${GREEN}Instalación de paquetes completada.${NC}"
        else
            echo -e "${GREEN}Todos los paquetes necesarios ya están instalados.${NC}"
        fi
    else
        echo -e "${BLUE}No se detectó pacman. Debes instalar manualmente los paquetes listados en el script.${NC}"
    fi
}

install_packages

echo -e "${GREEN}Configuración completada.${NC}"
