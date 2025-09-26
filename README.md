# Pop!_OS Setup Commands

```bash
# System Update
sudo apt update
sudo apt upgrade -y

# Alle APT Pakete
sudo apt install -y flatpak zsh build-essential gcc make cmake neovim software-properties-common htop tree unzip lutris mangohud syncthing keepassxc deja-dup

# Flatpak Setup
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Zsh als Standard-Shell
chsh -s /usr/bin/zsh

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

# LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Discord
flatpak install -y flathub com.discordapp.Discord

# Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Services starten
systemctl --user enable syncthing
systemctl --user start syncthing
```
