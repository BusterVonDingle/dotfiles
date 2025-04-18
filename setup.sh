#!/bin/bash

set -e

# Colors
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${GREEN}>>> Starting KDE + X11 + Picom dotfiles setup...${RESET}"

# Install base packages
if [ -f pkglist.txt ]; then
  echo -e "${GREEN}>>> Installing packages from pkglist.txt...${RESET}"
  xargs -a pkglist.txt sudo pacman -S --needed --noconfirm
else
  echo -e "${RED}pkglist.txt not found. Skipping system package installation.${RESET}"
fi

# Install AUR packages
if command -v yay &> /dev/null && [ -f aurlist.txt ]; then
  echo -e "${GREEN}>>> Installing AUR packages from aurlist.txt...${RESET}"
  xargs -a aurlist.txt yay -S --needed --noconfirm
else
  echo -e "${YELLOW}Skipping AUR packages. 'yay' not found or aurlist.txt missing.${RESET}"
fi

# Create symlinks with stow
echo -e "${GREEN}>>> Creating symlinks using stow...${RESET}"
for dir in .icons autostart fish gtk-3.0 gtk-4.0 htop icons konsole neofetch picom; do
  if [ -d "$dir" ]; then
    stow "$dir"
  else
    echo -e "${YELLOW}Skipping $dir — directory not found.${RESET}"
  fi
done

# Copy loose config files
echo -e "${GREEN}>>> Copying loose KDE config files...${RESET}"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

for file in kdeglobals kglobalshortcutsrc kscreenlockerrc ksmserverrc kwinrc plasmarc plasmashellrc; do
  if [ -f "$file" ]; then
    cp -v "$file" "$CONFIG_DIR/$file"
  else
    echo -e "${YELLOW}Skipping $file — file not found.${RESET}"
  fi
done

# Restart KWin and Plasma
read -p $'\e[33m>>> Restart Plasma shell and KWin now? (y/n): \e[0m' answer
if [[ "$answer" == [Yy]* ]]; then
  echo -e "${GREEN}>>> Restarting KWin and Plasma shell...${RESET}"
  kquitapp5 plasmashell && kstart5 plasmashell &
  kquitapp5 kwin && kstart5 kwin_x11 &
fi

echo -e "${GREEN}>>> Setup complete! You may need to log out and back in for all changes to take effect.${RESET}"
