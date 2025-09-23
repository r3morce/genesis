#!/bin/bash

# openSUSE Software Installation Script
# Installiert Software in optimaler Reihenfolge

set -e  # Script bei Fehlern beenden

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging Funktion
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "Dieses Script sollte nicht als root ausgeführt werden!"
   exit 1
fi

# System Update
log "System wird aktualisiert..."
sudo zypper refresh
sudo zypper update -y

echo ""
echo "=================================="
echo "Phase 1: System-Grundlagen"
echo "=================================="

# 1. Zsh Installation
log "Installiere Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo zypper install -y zsh
    success "Zsh installiert"
    
    # Shell wechseln
    log "Wechsle Standard-Shell zu Zsh..."
    chsh -s /usr/bin/zsh
    success "Standard-Shell auf Zsh gesetzt"
else
    warning "Zsh ist bereits installiert"
fi

# 2. P10k Installation
log "Installiere Powerlevel10k..."
if [ ! -d "$HOME/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
    success "Powerlevel10k installiert"
else
    warning "Powerlevel10k ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Phase 2: Daten-Synchronisation"
echo "=================================="

# 3. Syncthing Installation
log "Installiere Syncthing..."
if ! command -v syncthing &> /dev/null; then
    sudo zypper install -y syncthing
    systemctl --user enable syncthing
    systemctl --user start syncthing
    success "Syncthing installiert und gestartet"
    log "Syncthing läuft auf: http://127.0.0.1:8384"
else
    warning "Syncthing ist bereits installiert"
fi

# 4. KeepassXC Installation
log "Installiere KeepassXC..."
if ! command -v keepassxc &> /dev/null; then
    sudo zypper install -y keepassxc
    success "KeepassXC installiert"
else
    warning "KeepassXC ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Phase 3: Entwicklungstools"
echo "=================================="

# 5. LazyVim (benötigt Neovim)
log "Installiere Neovim und LazyVim..."
if ! command -v nvim &> /dev/null; then
    sudo zypper install -y neovim git
    success "Neovim installiert"
else
    warning "Neovim ist bereits installiert"
fi

# LazyVim Setup
if [ ! -d "$HOME/.config/nvim" ]; then
    log "Installiere LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    success "LazyVim installiert"
else
    warning "Neovim Konfiguration existiert bereits"
fi

echo ""
echo "=================================="
echo "Phase 4: Desktop-Anwendungen"
echo "=================================="

# 6. Firefox Installation
log "Installiere Firefox..."
if ! command -v firefox &> /dev/null; then
    sudo zypper install -y firefox
    success "Firefox installiert"
else
    warning "Firefox ist bereits installiert"
fi

# 7. Discord Installation (via Flatpak)
log "Installiere Discord..."
if ! command -v flatpak &> /dev/null; then
    sudo zypper install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flatpak installiert"
fi

if ! flatpak list | grep -q "com.discordapp.Discord"; then
    flatpak install -y flathub com.discordapp.Discord
    success "Discord installiert"
else
    warning "Discord ist bereits installiert"
fi

# 8. Steam Installation
log "Installiere Steam..."
if ! command -v steam &> /dev/null; then
    # Steam Repository hinzufügen
    sudo zypper addrepo -f https://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
    sudo zypper refresh
    sudo zypper install -y steam steam-devices
    success "Steam installiert"
else
    warning "Steam ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Phase 5: System-Tools"
echo "=================================="

# 9. Deja Dup Installation
log "Installiere Deja Dup..."
if ! command -v deja-dup &> /dev/null; then
    sudo zypper install -y deja-dup
    success "Deja Dup installiert"
else
    warning "Deja Dup ist bereits installiert"
fi

# 10. Tailscale Installation
log "Installiere Tailscale..."
if ! command -v tailscale &> /dev/null; then
    log "Lade Tailscale Installationsscript..."
    curl -fsSL https://tailscale.com/install.sh | sh
    success "Tailscale installiert"
    log "Führe 'sudo tailscale up' aus, um Tailscale zu aktivieren"
else
    warning "Tailscale ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Installation abgeschlossen!"
echo "=================================="

success "Alle Programme wurden erfolgreich installiert!"
echo ""
echo "Nächste Schritte:"
echo "1. Starte dein System neu, um Zsh zu aktivieren"
echo "2. Konfiguriere Syncthing unter http://127.0.0.1:8384"
echo "3. Importiere deinen KeePass-Tresor"
echo "4. Aktiviere Tailscale mit: sudo tailscale up"
echo "5. Starte Powerlevel10k Konfiguration mit: p10k configure"
echo ""
warning "WICHTIG: Nach dem Neustart läuft Zsh als Standard-Shell!"
