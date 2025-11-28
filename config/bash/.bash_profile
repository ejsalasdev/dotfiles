# ~/.bash_profile: ejecutado por la shell de login para usuarios
# Esta configuración carga .bashrc para shells interactivas.

# Si Bash está corriendo, y es una shell interactiva, carga .bashrc
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi
