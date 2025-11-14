#!/bin/bash

# --- Configuración ---
DOTFILES_DIR="$HOME/dotfiles"
NVIM_VERSION="0.11.0"
NVIM_TAR_GZ="nvim-linux-x86_64.tar.gz"
NVIM_INSTALL_PATH="/opt/neovim"

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

# --- 1. Actualizar el sistema ---
log_info "Actualizando el sistema..."
sudo nala update && sudo nala upgrade -y || log_error "Fallo al actualizar el sistema."

# --- 2. Instalar paquetes esenciales ---
log_info "Instalando paquetes esenciales..."
sudo nala install -y \
    xorg \
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
    || log_error "Fallo al instalar paquetes esenciales."

# --- 3. Instalar Oh My Zsh ---
log_info "Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Fallo al instalar Oh My Zsh."
else
    log_warn "Oh My Zsh ya está instalado. Saltando instalación."
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
log_info "Instalando Neovim $NVIM_VERSION..."
# Verificar si Neovim ya está instalado y es la versión deseada
CURRENT_NVIM_VERSION=$( "$NVIM_INSTALL_PATH/bin/nvim" --version 2>/dev/null | head -n 1 | awk '{print $2}' | sed 's/^v//')
if [ ! -d "$NVIM_INSTALL_PATH" ] || [ ! -f "$NVIM_INSTALL_PATH/bin/nvim" ] || [ "$CURRENT_NVIM_VERSION" != "$NVIM_VERSION" ]; then
    log_info "Descargando Neovim $NVIM_VERSION..."
    # Usar un directorio temporal para la descarga para evitar conflictos si el script se ejecuta desde ~/Descargas
    TEMP_DOWNLOAD_DIR=$(mktemp -d)
    curl -L "https://github.com/neovim/neovim/releases/download/v$NVIM_VERSION/$NVIM_TAR_GZ" -o "$TEMP_DOWNLOAD_DIR/$NVIM_TAR_GZ" || log_error "Fallo al descargar Neovim."
    
    sudo rm -rf "$NVIM_INSTALL_PATH"
    sudo tar -C /opt -xzf "$TEMP_DOWNLOAD_DIR/$NVIM_TAR_GZ" || log_error "Fallo al extraer Neovim."
    sudo mv "/opt/nvim-linux-x86_64" "$NVIM_INSTALL_PATH" || log_error "Fallo al renombrar directorio de Neovim."
    rm -rf "$TEMP_DOWNLOAD_DIR" # Limpiar el directorio temporal
else
    log_warn "Neovim $NVIM_VERSION ya está instalado en $NVIM_INSTALL_PATH. Saltando instalación."
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

# .config/nvim (kickstart)
log_info "Configurando kickstart.nvim..."
# Primero, eliminar la configuración existente de nvim para asegurar una instalación limpia de kickstart
rm -rf "$HOME/.config/nvim"
git clone https://github.com/folke/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim" || log_error "Fallo al clonar kickstart.nvim."

# --- 7. Configurar Zsh como shell por defecto ---
log_info "Configurando Zsh como shell por defecto..."
if [ "$(basename "$SHELL")" != "zsh" ]; then
    chsh -s "$(which zsh)" || log_error "Fallo al cambiar el shell por defecto a Zsh. Por favor, hazlo manualmente con 'chsh -s \\
$(which zsh)' y reinicia tu sesión."
else
    log_warn "Zsh ya es el shell por defecto. Saltando configuración."
fi

# --- 8. Crear ~/.xinitrc para iniciar i3 ---
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
chmod +x "$HOME/.xinitrc" # Asegurarse de que sea ejecutable

# --- 9. Pasos finales y recomendación de reinicio ---
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
