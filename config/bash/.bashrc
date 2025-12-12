# --- .bashrc ---

# 1. BLE.SH (Debe ser lo primero)
if [ -f "$HOME/.local/share/blesh/ble.sh" ]; then
    [[ $- == *i* ]] && source "$HOME/.local/share/blesh/ble.sh" --noattach
fi

# Si no es interactivo, salir
[[ $- != *i* ]] && return

# 2. Historial
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend

# 3. Opciones de Bash
shopt -s checkwinsize
shopt -s globstar
shopt -s autocd

# 4. Prompt (Starship)
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# 5. Autocompletado
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# 6. FZF
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)"
fi

# 7. Configuración Modular
# Cargar Alias
if [ -f "$HOME/dotfiles/config/bash/aliases.bash" ]; then
    source "$HOME/dotfiles/config/bash/aliases.bash"
fi

# Cargar Secretos (No en Git)
if [ -f "$HOME/.bash_secrets" ]; then
    source "$HOME/.bash_secrets"
fi

# 8. Colores Man
export LESS_TERMCAP_mb=$"\e[1;32m"
export LESS_TERMCAP_md=$"\e[1;32m"
export LESS_TERMCAP_me=$"\e[0m"
export LESS_TERMCAP_se=$"\e[0m"
export LESS_TERMCAP_so=$"\e[01;33m"
export LESS_TERMCAP_ue=$"\e[0m"
export LESS_TERMCAP_us=$"\e[1;4;31m"

# 9. NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 10. Adjuntar BLE.SH (Al final)
[[ ${BLE_VERSION-} ]] && ble-attach

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/d0s/.sdkman"
[[ -s "/home/d0s/.sdkman/bin/sdkman-init.sh" ]] && source "/home/d0s/.sdkman/bin/sdkman-init.sh"
