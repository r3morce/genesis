# Package Commands

## System Update
```bash
sudo apt update
sudo apt upgrade -y
```

## APT Packages
```bash
sudo apt install -y \
  flatpak zsh build-essential gcc make cmake neovim \
  software-properties-common tree unzip \
  lutris syncthing keepassxc \
  discord vlc wezterm ffmpeg
```

## Flatpak
```bash
# Setup Flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install apps
flatpak install -y flathub \
  com.yubico.yubioath \
  md.obsidian.Obsidian
```

## Zsh Setup
```bash
# Set Zsh as default shell
chsh -s /usr/bin/zsh

# Install Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
```

## LazyVim
```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

## Tailscale
```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

## NPM Global (Claude Code)
```bash
# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Install Node.js
nvm install 22.20.0
nvm use 22.20.0

# Install Claude Code
npm install -g @anthropic-ai/claude-code
```

## Services
```bash
# Enable and start Syncthing
systemctl --user enable syncthing
systemctl --user start syncthing
```
