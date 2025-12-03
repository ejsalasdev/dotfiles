#!/bin/bash

# Colores para logs
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Iniciando configuración de Dotfiles...${NC}"

# Directorio base de los dotfiles (donde está este script)
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# --- FUNCIONES ---

create_symlink() {
    local source=$1
    local target=$2

    # Crear directorio padre si no existe
    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
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

install_blesh() {
    echo -e "\n${BLUE}Verificando ble.sh (Bash Line Editor)...${NC}"
    if [ ! -f "$HOME/.local/share/blesh/ble.sh" ]; then
        echo -e "${BLUE}Instalando ble.sh...${NC}"
        mkdir -p "$HOME/.local/src"
        if [ -d "$HOME/.local/src/ble.sh" ]; then
            rm -rf "$HOME/.local/src/ble.sh"
        fi
        git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$HOME/.local/src/ble.sh"
        make -C "$HOME/.local/src/ble.sh" install PREFIX="$HOME/.local"
        echo -e "${GREEN}ble.sh instalado.${NC}"
    else
        echo -e "${BLUE}ble.sh ya está instalado.${NC}"
    fi
}

install_packages() {
    echo -e "\n${BLUE}Verificando paquetes necesarios...${NC}"
    
    if command -v pacman &> /dev/null; then
        
        CORE_PKGS=(
            "hyprland" "kitty" "waybar" "wofi" "hyprpaper" "dunst" "libnotify" 
            "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk" 
            "polkit-gnome" "hyprlock" "hypridle" "hyprpicker"
        )
        
        FILE_MANAGER_PKGS=(
            "thunar" "thunar-volman" "thunar-archive-plugin" 
            "tumbler" "ffmpegthumbnailer" "poppler-glib" "imagemagick" 
            "gvfs" "gvfs-mtp" "file-roller" 
            "zip" "unzip" "unrar" "p7zip"
        )
        
        AUDIO_PKGS=(
            "pipewire" "pipewire-pulse" "wireplumber" "pavucontrol" "pamixer"
        )
        
        THEME_PKGS=(
            "gnome-themes-extra" "papirus-icon-theme" 
            "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji"
        )
        
        UTILS_PKGS=(
            "grim" "slurp" "wl-clipboard" "git" "curl" "brightnessctl"
            "starship" "bash-completion" "fzf" "eza" "bat" "bc" "make" "man-db" "sane-airscan"
	    "ntfs-3g" "cliphist"
        )

        APPS_PKGS=(
            "firefox" "firefox-i18n-es-mx"
            "vlc"
            "feh"
            "cups" "cups-pdf" "cups-filters" "gutenprint" "simple-scan"
            "libreoffice-still" "libreoffice-still-es"
        )

        ALL_PACKAGES=("${{CORE_PKGS[@]}}" "${{FILE_MANAGER_PKGS[@]}}" "${{AUDIO_PKGS[@]}}" "${{THEME_PKGS[@]}}" "${{UTILS_PKGS[@]}}" "${{APPS_PKGS[@]}}")
        TO_INSTALL=()

        echo -e "${BLUE}Comprobando ${{#ALL_PACKAGES[@]}} paquetes...${NC}"

        for pkg in "${{ALL_PACKAGES[@]}}"; do
            if ! pacman -Qi $pkg &> /dev/null; then
                TO_INSTALL+=("$pkg")
            fi
        done

        if [ ${{#TO_INSTALL[@]}} -gt 0 ]; then
            echo -e "${BLUE}Instalando paquetes faltantes: ${{TO_INSTALL[*]}}${NC}"
            sudo pacman -S --noconfirm --needed "${{TO_INSTALL[@]}}"
            echo -e "${GREEN}Instalación de paquetes completada.${NC}"
        else
            echo -e "${GREEN}Todos los paquetes necesarios ya están instalados.${NC}"
        fi
    else
        echo -e "${BLUE}No se detectó pacman. Instalación manual requerida.${NC}"
    fi
}

enable_services() {
    echo -e "\n${BLUE}Habilitando servicios del sistema...${NC}"
    if command -v systemctl &> /dev/null; then
        echo -e "${BLUE}Habilitando CUPS...${NC}"
        sudo systemctl enable cups.service
        echo -e "${GREEN}Servicio CUPS habilitado.${NC}"
    fi
}

# --- EJECUCIÓN ---

# 1. Crear directorios
echo -e "\n${BLUE}Creando directorios de usuario...${NC}"
mkdir -p "$HOME/Imágenes/Capturas de pantalla"

# 2. Crear enlaces simbólicos
echo -e "\n${BLUE}Creando enlaces simbólicos...${NC}"
create_symlink "$DOTFILES_DIR/config/bash/.bashrc" "$HOME/.bashrc"
create_symlink "$DOTFILES_DIR/config/bash/blerc" "$HOME/.blerc"
create_symlink "$DOTFILES_DIR/config/hypr" "$HOME/.config/hypr"
create_symlink "$DOTFILES_DIR/config/kitty" "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/config/wofi" "$HOME/.config/wofi"
create_symlink "$DOTFILES_DIR/config/waybar" "$HOME/.config/waybar"
create_symlink "$DOTFILES_DIR/config/dunst" "$HOME/.config/dunst"
create_symlink "$DOTFILES_DIR/config/gtk-3.0" "$HOME/.config/gtk-3.0"
create_symlink "$DOTFILES_DIR/config/nvim" "$HOME/.config/nvim"

# 3. Instalar paquetes del sistema
install_packages

# 4. Instalar herramientas locales (Ble.sh)
install_blesh

# 5. Habilitar servicios
enable_services

echo -e "\n${GREEN}Configuración completada exitosamente.${NC}"