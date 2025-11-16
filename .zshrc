# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load.
ZSH_THEME="simple"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration
# NVM (Node Version Manager) configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Custom Aliases
# -----------------------------------------------------------------------------
alias v='nvim'

# Navegación rápida a directorios de configuración
alias cdc='cd ~/.config'
alias cdi3='cd ~/.config/i3'
alias cdrofi='cd ~/.config/rofi'

# Edición rápida de archivos de configuración
alias ei3='nvim ~/.config/i3/config' # O 'nano' o 'vim' si no usas nvim
alias ezsh='nvim ~/.zshrc'           # O 'nano' o 'vim'
alias erofi='nvim ~/.config/rofi/config.rasi' # O 'nano' o 'vim'

# Comandos útiles para i3
alias i3r='i3-msg reload' # Recargar la configuración de i3
alias i3restart='i3-msg restart' # Reiniciar i3 (mantiene la sesión)

# Listado de archivos mejorado con eza
alias ls='eza'
alias ll='eza -lah' # Listar archivos con detalles, ocultos y en formato legible
alias la='eza -a'   # Listar todos los archivos, incluyendo ocultos

# Visualización de directorios con tree
alias tree='tree -L 2' # Muestra el árbol de directorios hasta 2 niveles de profundidad

# Gestión de paquetes con nala (alias simplificados)
alias upd='sudo nala update' # Actualizar solo la lista de repositorios
alias up='sudo nala update && sudo nala upgrade -y' # Actualizar repositorios y paquetes
alias se='nala search' # Buscar paquetes
alias cl='sudo nala clean' # Limpiar la caché de paquetes
alias rmv='sudo nala autoremove -y' # Eliminar paquetes no usados y dependencias huérfanas
alias in='sudo nala install -y' # Instalar paquetes
alias un='sudo nala remove -y' # Desinstalar paquetes

# fzf configuration
source /usr/share/doc/fzf/examples/completion.zsh
source /usr/share/doc/fzf/examples/key-bindings.zsh

# Configure PATH for Neovim and user local binaries
export PATH="/opt/neovim/bin:$HOME/.local/bin:$PATH"
