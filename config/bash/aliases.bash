# --- Navegación y Listado (eza) ---
alias ls='eza --icons --group-directories-first'
alias ll='eza -alh --icons --group-directories-first'
alias lt='eza --tree --level=2 --icons'

# --- Arch Linux (Pacman) ---
alias in='sudo pacman -S'
alias un='sudo pacman -Rns'
alias up='sudo pacman -Syu'
alias se='pacman -Ss'
alias unlock='sudo rm /var/lib/pacman/db.lck'
alias cu='sudo pacman -Rns $(pacman -Qtdq)'
alias cc='sudo pacman -Sc'
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'

# --- Utilidades ---
alias cat='bat'
alias grep='grep --color=auto'
alias c='clear'
alias h='history'
alias ..='cd ..'
alias ...='cd ../..'
alias dots='cd ~/dotfiles'

# --- Seguridad ---
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'
