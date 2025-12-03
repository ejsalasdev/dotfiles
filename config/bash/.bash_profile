# ~/.bash_profile: ejecutado por la shell de login para usuarios
# Esta configuración carga .bashrc para shells interactivas.

# Si Bash está corriendo, y es una shell interactiva, carga .bashrc
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi


# Start ssh-agent if it is not running and load keys
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -s > ~/.ssh/ssh-agent-env
fi

if [[ -f ~/.ssh/ssh-agent-env ]]; then
    . ~/.ssh/ssh-agent-env > /dev/null
fi
