# 🌌 Arch Linux + Hyprland Dotfiles

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-00A4A6?style=for-the-badge&logo=nixos&logoColor=white)

Configuración personal minimalista y altamente funcional para **Arch Linux** usando el compositor **Hyprland**.

El objetivo de este proyecto es proporcionar un entorno de trabajo fluido, estético (Dark Theme) y automatizado, listo para desplegarse en una instalación base de Arch.

## 📸 Preview

![Screenshot](./screenshot.png)

## 🛠️ Tech Stack

| Componente | Herramienta | Descripción |
|------------|-------------|-------------|
| **OS** | Arch Linux | Instalación minimalista |
| **WM** | Hyprland | Compositor Wayland dinámico |
| **Terminal** | Kitty | Rápida, basada en GPU |
| **Barra** | Waybar | Estilo moderno con soporte OSD |
| **Lanzador** | Wofi | Estilo Spotlight/Alfred |
| **Notificaciones** | Dunst | Integración con scripts OSD personalizados |
| **Archivos** | Thunar | Con soporte completo (zip, rar, thumbnails) |
| **Tema** | Adwaita-Dark | + Iconos Papirus |
| **Fuentes** | Nerd Fonts | JetBrains Mono |

## ✨ Características Destacadas

- **Instalación Automatizada**: Script `install.sh` inteligente que gestiona paquetes (pacman), enlaces simbólicos y configuraciones.
- **OSD Personalizado**: Scripts propios (`scripts/osd.sh`) para notificaciones visuales de Volumen, Brillo y Bloq Mayús con lógica *debounce*.
- **Estilo Coherente**: Bordes redondeados, paleta de colores oscuros (`#1e1e2e`) y acentos Cyan (`#33ccff`) en todo el sistema (Wofi, Waybar, Dunst, Hyprland).
- **Gestión de Ventanas**: Layout *Dwindle* configurado para productividad.

## 🚀 Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/ejsalasdev/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Ejecutar el script de instalación:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   > El script detectará paquetes faltantes (Waybar, Fuentes, Thunar, etc.) y los instalará automáticamente usando `sudo pacman`. También creará los enlaces simbólicos necesarios en `~/.config`.

## ⌨️ Atajos de Teclado (Keybindings)

| Atajo | Acción |
|-------|--------|
| `SUPER + RETURN` | Abrir Terminal (Kitty) |
| `SUPER + Q` | Cerrar ventana activa |
| `SUPER + SPACE` | Lanzador de aplicaciones (Wofi) |
| `SUPER + E` | Gestor de Archivos (Thunar) |
| `SUPER + SHIFT + R` | Recargar configuración (Hyprland/Waybar) |
| `SUPER + M` | Salir de la sesión |
| `SUPER + L` | Bloquear pantalla (Hyprlock) |
| `SUPER + Arrow Keys` | Redimensionar ventana activa |
| `SUPER + SHIFT + Arrow Keys` | Mover foco entre ventanas |
| `SUPER + SHIFT + Left/Right` | Mover ventana a workspace |
| `PRINT` | Captura de pantalla completa (al portapapeles) |
| `SUPER + PRINT` | Captura de región (al portapapeles) |
| `SUPER + SHIFT + C` | Selector de color (Hyprpicker) |
| `Teclas Multimedia` | Control de Volumen y Brillo (con OSD) |

## 📂 Estructura del Proyecto

```text
~/dotfiles
├── config/
│   ├── dunst/       # Notificaciones
│   ├── gtk-3.0/     # Tema GTK Oscuro
│   ├── hypr/        # Hyprland Config
│   ├── kitty/       # Terminal
│   ├── waybar/      # Barra de estado
│   └── wofi/        # Lanzador
├── scripts/
│   └── osd.sh       # Lógica de notificaciones OSD
├── install.sh       # Script de despliegue
└── README.md        # Documentación
```
