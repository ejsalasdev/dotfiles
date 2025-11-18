#!/bin/bash

# --- Configuración ---
DOTFILES_DIR="$HOME/dotfiles"
NVIM_TAR_GZ="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_PATH="/opt/neovim"
WALLPAPER_SOURCE="$DOTFILES_DIR/assets/bg/firewatch.jpg"
WALLPAPER_DEST="$HOME/Imágenes/firewatch.jpg"

# --- Funciones de ayuda ---
log_info() {
    echo -e "\e[32mINFO:\e[0m $1"
}

log_warn() {
    echo -e "\e[33mWARN:\e[0m $1"
}

log_error() {
    echo -e "\e[31mERROR:\e[0m $1"
    exit 1
}

# Función para asegurar que nala esté instalado
ensure_nala() {
    if ! command -v nala &> /dev/null; then
        log_info "Nala no encontrado. Instalando Nala..."
        sudo apt update || log_error "Fallo al actualizar apt."
        sudo apt install -y nala || log_error "Fallo al instalar Nala."
    else
        log_warn "Nala ya está instalado. Saltando instalación."
    fi
}

# --- 0. Asegurar Nala ---
ensure_nala

# --- 1. Actualizar el sistema ---
log_info "Actualizando el sistema..."
sudo nala update && sudo nala upgrade -y || log_error "Fallo al actualizar el sistema."

# --- 2. Instalar paquetes esenciales ---
log_info "Instalando paquetes esenciales..."
sudo nala install -y \
    xorg \
    i3 \
    build-essential \
    git \
    zsh \
    alacritty \
    rofi \
    feh \
    picom \
    lxappearance \
    arc-theme \
    papirus-icon-theme \
    thunar \
    thunar-archive-plugin \
    unzip \
    p7zip-full \
    unrar-free \
    gvfs-backends \
    samba-client \
    cifs-utils \
    thunar-volman \
    tumbler \
    ffmpegthumbnailer \
    fzf \
    xclip \
    python3-pynvim \
    curl \
    fastfetch \
    eza \
    tree \
    bat \
    pipewire \
    pipewire-pulse \
    wireplumber \
    libspa-0.2-bluetooth \
    pavucontrol \
    xbacklight \
    x11-utils \
    polybar \
    dex \
    i3lock \
    xss-lock \
    network-manager-gnome \
    flameshot \
    xdg-desktop-portal-gtk \
    dconf-cli \
    dunst \
    libnotify-bin \
    fonts-font-awesome \
    fonts-jetbrains-mono \
    || log_error "Fallo al instalar paquetes esenciales."

# --- 3. Instalar Oh My Zsh ---
log_info "Instalando Oh My Zsh..."
# Asegurarse de que git esté disponible para el instalador de Oh My Zsh
if ! command -v git &> /dev/null; then
    log_error "Git no está instalado, es necesario para Oh My Zsh."
fi

if [ ! -d "$HOME/.oh-my-zsh" ] || [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_warn "Instalación de Oh My Zsh incompleta. Eliminando y reinstalando."
        rm -rf "$HOME/.oh-my-zsh"
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Fallo al instalar Oh My Zsh."
else
    log_warn "Oh My Zsh ya está instalado y completo. Saltando instalación."
fi

# --- 4. Instalar plugins de Zsh ---
log_info "Instalando plugins de Zsh..."
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || log_error "Fallo al clonar zsh-autosuggestions."
else
    log_warn "zsh-autosuggestions ya está instalado. Saltando clonación."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || log_error "Fallo al clonar zsh-syntax-highlighting."
else
    log_warn "zsh-syntax-highlighting ya está instalado. Saltando clonación."
fi

# --- 5. Instalar Neovim (versión reciente) ---
log_info "Instalando la última versión de Neovim..."

# Obtener la última versión de Neovim
NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep "tag_name" | cut -d '"' -f 4 | sed 's/^v//')
if [ -z "$NVIM_VERSION" ]; then
    log_error "Fallo al obtener la última versión de Neovim de GitHub."
fi
log_info "Última versión de Neovim encontrada: v$NVIM_VERSION"

# Verificar si Neovim ya está instalado y es la versión deseada
CURRENT_NVIM_VERSION=$("$NVIM_INSTALL_PATH/bin/nvim" --version 2>/dev/null | head -n 1 | awk '{print $2}' | sed 's/^v//')
if [ ! -d "$NVIM_INSTALL_PATH" ] || [ ! -f "$NVIM_INSTALL_PATH/bin/nvim" ] || [ "$CURRENT_NVIM_VERSION" != "$NVIM_VERSION" ]; then
    log_info "Descargando Neovim v$NVIM_VERSION..."
    # Usar un directorio temporal para la descarga
    TEMP_DOWNLOAD_DIR=$(mktemp -d)
    curl -L "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/$NVIM_TAR_GZ" -o "$TEMP_DOWNLOAD_DIR/$NVIM_TAR_GZ" || log_error "Fallo al descargar Neovim."
    
    sudo rm -rf "$NVIM_INSTALL_PATH"
    sudo tar -C /opt -xzf "$TEMP_DOWNLOAD_DIR/$NVIM_TAR_GZ" || log_error "Fallo al extraer Neovim."
    sudo mv "/opt/nvim-linux-x86_64" "$NVIM_INSTALL_PATH" || log_error "Fallo al renombrar directorio de Neovim."
    rm -rf "$TEMP_DOWNLOAD_DIR" # Limpiar el directorio temporal
else
    log_warn "Neovim v$NVIM_VERSION ya está instalado en $NVIM_INSTALL_PATH. Saltando instalación."
fi

# --- 6. Desplegar Dotfiles (crear enlaces simbólicos) ---
log_info "Desplegando dotfiles..."

# .zshrc
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc" || log_error "Fallo al enlazar .zshrc"

# .config/i3
mkdir -p "$HOME/.config/i3"
ln -sf "$DOTFILES_DIR/.config/i3/config" "$HOME/.config/i3/config" || log_error "Fallo al enlazar i3/config"
mkdir -p "$HOME/.config/i3/scripts"
ln -sf "$DOTFILES_DIR/.config/i3/scripts/exit_prompt.sh" "$HOME/.config/i3/scripts/exit_prompt.sh" || log_error "Fallo al enlazar i3/scripts/exit_prompt.sh"

# .config/rofi
mkdir -p "$HOME/.config/rofi"
ln -sf "$DOTFILES_DIR/.config/rofi/config.rasi" "$HOME/.config/rofi/config.rasi" || log_error "Fallo al enlazar rofi/config.rasi"
mkdir -p "$HOME/.config/rofi/scripts"
ln -sf "$DOTFILES_DIR/.config/rofi/scripts/powermenu.sh" "$HOME/.config/rofi/scripts/powermenu.sh" || log_error "Fallo al enlazar rofi/powermenu.sh"
ln -sf "$DOTFILES_DIR/.config/rofi/powermenu.rasi" "$HOME/.config/rofi/powermenu.rasi" || log_error "Fallo al enlazar rofi/powermenu.rasi"
ln -sf "$DOTFILES_DIR/.config/rofi/confirm.rasi" "$HOME/.config/rofi/confirm.rasi" || log_error "Fallo al enlazar rofi/confirm.rasi"

# Clonar temas de Rofi
if [ ! -d "$HOME/.config/rofi/rofi-themes" ]; then
    log_info "Clonando temas de Rofi..."
    git clone https://github.com/adi1090x/rofi.git "$HOME/.config/rofi/rofi-themes" || log_error "Fallo al clonar los temas de Rofi."
else
    log_warn "El directorio de temas de Rofi ya existe. Saltando clonación."
fi

# .config/polybar
mkdir -p "$HOME/.config/polybar"
ln -sf "$DOTFILES_DIR/.config/polybar/config.ini" "$HOME/.config/polybar/config.ini" || log_error "Fallo al enlazar polybar/config.ini"
ln -sf "$DOTFILES_DIR/.config/polybar/launch.sh" "$HOME/.config/polybar/launch.sh" || log_error "Fallo al enlazar polybar/launch.sh"

# .config/dunst
mkdir -p "$HOME/.config/dunst"
ln -sf "$DOTFILES_DIR/.config/dunst/dunstrc" "$HOME/.config/dunst/dunstrc" || log_error "Fallo al enlazar dunstrc"

# .config/gtk-3.0
mkdir -p "$HOME/.config/gtk-3.0"
ln -sf "$DOTFILES_DIR/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini" || log_error "Fallo al enlazar gtk-3.0/settings.ini"

# .config/gtk-2.0
mkdir -p "$HOME/.config/gtk-2.0"
ln -sf "$DOTFILES_DIR/.config/gtk-2.0/gtkrc" "$HOME/.config/gtk-2.0/gtkrc" || log_error "Fallo al enlazar gtk-2.0/gtkrc"

# .config/alacritty
mkdir -p "$HOME/.config/alacritty"
ln -sf "$DOTFILES_DIR/.config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" || log_error "Fallo al enlazar alacritty.toml"

# .config/nvim (kickstart)
log_info "Configurando kickstart.nvim..."
# Primero, eliminar la configuración existente de nvim para asegurar una instalación limpia de kickstart
rm -rf "$HOME/.config/nvim"
git clone https://github.com/folke/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" || log_error "Fallo al clonar kickstart.nvim."

# --- 7. Configurar Zsh como shell por defecto ---
log_info "Configurando Zsh como shell por defecto..."
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)" || log_error "Fallo al cambiar el shell por defecto a Zsh. Por favor, hazlo manualmente con 'chsh -s \$(which zsh)' y reinicia tu sesión."
else
    log_warn "Zsh ya es el shell por defecto. Saltando configuración."
fi

# --- 8. Configurar entorno para Neovim ---
log_info "Configuración del PATH de Neovim gestionada en .zshrc."

# --- 9. Crear ~/.xinitrc para iniciar i3 ---
log_info "Creando ~/.xinitrc para iniciar i3..."
if [ ! -f "$HOME/.xinitrc" ]; then
    echo "exec i3" > "$HOME/.xinitrc" || log_error "Fallo al crear ~/.xinitrc."
    log_info "Archivo ~/.xinitrc creado con 'exec i3'."
else
    # Verificar si ya contiene 'exec i3'
    if ! grep -q "exec i3" "$HOME/.xinitrc"; then
        echo "exec i3" >> "$HOME/.xinitrc" || log_error "Fallo al añadir 'exec i3' a ~/.xinitrc."
        log_info "Añadido 'exec i3' a ~/.xinitrc."
    else
        log_warn "~/.xinitrc ya existe y contiene 'exec i3'. Saltando creación."
    fi
fi

# --- 10. Copiar fondo de pantalla ---
log_info "Copiando fondo de pantalla..."
mkdir -p "$HOME/Imágenes" || log_error "Fallo al crear el directorio $HOME/Imágenes."
cp "$WALLPAPER_SOURCE" "$WALLPAPER_DEST" || log_error "Fallo al copiar el fondo de pantalla."

# --- 11. Pasos finales y recomendación de reinicio ---
log_info "Instalación de dotfiles completada."
log_info "Por favor, abre Neovim (nvim) para que instale sus plugins."
log_info "Si es la primera vez, es posible que necesites reiniciar tu sesión de X para que todos los cambios surtan efecto."

read -p "¿Deseas reiniciar el sistema ahora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    log_info "Reiniciando el sistema..."
    sudo reboot
else
    log_info "Reinicio pospuesto. Recuerda reiniciar manualmente para que todos los cambios surtan efecto."
fi

