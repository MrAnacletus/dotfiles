#!/usr/bin/env bash
set -e

# =====================================
# Arch Linux Base Setup Script
# Assumes: Zsh + Oh My Zsh already exist
# =====================================

# ---- Sudo keep-alive ----
if [[ $EUID -ne 0 ]]; then
  echo "Este script debe ejecutarse con sudo"
  exit 1
fi

echo "▶ Iniciando setup de Arch..."

# -------------------------------------
# 1. Paquetes base (pacman)
# -------------------------------------
echo "▶ Instalando paquetes base..."

pacman -S --needed --noconfirm \
  base-devel\
  git \
  firefox \
  jq \
  nautilus \
  gvfs \
  gvfs-mtp \
  waybar \
  papirus-icon-theme \
  mako \
  rofi \
  code \
  adw-gtk-theme \
  unzip \
  pipewire \
  pipewire-pulse \
  wireplumber \
  libnotify \
  pavucontrol \
  python \
  hyprshot

# -------------------------------------
# 2. Fuentes
# -------------------------------------
echo "▶ Instalando fuentes..."

pacman -S --needed --noconfirm \
  ttf-dejavu \
  ttf-liberation \
  noto-fonts \
  noto-fonts-emoji \
  ttf-fira-code \
  ttf-jetbrains-mono \
  ttf-jetbrains-mono-nerd

# -------------------------------------
# 3. Nerd Fonts Symbols (manual)
# -------------------------------------
echo "▶ Instalando Nerd Fonts Symbols..."

command -v curl >/dev/null || pacman -S --needed --noconfirm curl
SYMBOLS_DIR="/usr/local/share/fonts/NerdFontsSymbolsOnly"
if [[ ! -d "$SYMBOLS_DIR" ]]; then
  mkdir -p "$SYMBOLS_DIR"
  curl -L \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip \
    -o /tmp/NerdFontsSymbolsOnly.zip
  unzip -o /tmp/NerdFontsSymbolsOnly.zip -d "$SYMBOLS_DIR"
  rm /tmp/NerdFontsSymbolsOnly.zip
fi

# -------------------------------------
# 4. Font cache
# -------------------------------------
echo "▶ Actualizando cache de fuentes..."
fc-cache -fv

# -------------------------------------
# 5. GTK / Theming
# -------------------------------------
echo "▶ Configurando GTK y tema..."

sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
sudo -u "$SUDO_USER" gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 11'

# -------------------------------------
# 6. Locale (es_CL.UTF-8)
# -------------------------------------
echo "▶ Configurando locale es_CL.UTF-8..."

sed -i 's/^#es_CL.UTF-8 UTF-8/es_CL.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
localectl set-locale LANG=es_CL.UTF-8

# -------------------------------------
# 7. Final
# -------------------------------------
echo "✔ Setup completado correctamente."
echo "⚠ Reinicia sesión para aplicar locale y GTK."
