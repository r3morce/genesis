#!/bin/bash

# Pop!_OS Software Installation Script
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
sudo apt update && sudo apt upgrade -y

echo ""
echo "=================================="
echo "Phase 1: System-Grundlagen & Tools"
echo "=================================="

# 1. Basis-Tools zuerst installieren (für Repository-Management)
log "Installiere Basis-Tools..."
sudo apt install -y \
    curl \
    wget \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release
success "Basis-Tools installiert"

# 2. Zsh Installation
log "Installiere Zsh..."
if ! command -v zsh &> /dev/null; then
    sudo apt install -y zsh
    success "Zsh installiert"
    
    # Shell wechseln
    log "Wechsle Standard-Shell zu Zsh..."
    chsh -s /usr/bin/zsh
    success "Standard-Shell auf Zsh gesetzt"
else
    warning "Zsh ist bereits installiert"
fi

# 3. P10k Installation
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
    # Moderne Methode ohne apt-key (deprecated)
    wget -qO- https://syncthing.net/release-key.gpg | sudo tee /usr/share/keyrings/syncthing-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
    sudo apt update
    sudo apt install -y syncthing
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
    sudo apt install -y keepassxc
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
    # Neovim PPA für neueste Version (jetzt funktioniert add-apt-repository)
    sudo add-apt-repository ppa:neovim-ppa/unstable -y
    sudo apt update
    sudo apt install -y neovim git build-essential
    success "Neovim installiert"
else
    warning "Neovim ist bereits installiert"
    # Sicherstellen, dass build-essential installiert ist
    sudo apt install -y build-essential
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

# 6. Firefox ist bereits vorinstalliert
log "Firefox prüfen..."
if command -v firefox &> /dev/null; then
    success "Firefox ist bereits installiert"
else
    sudo apt install -y firefox
    success "Firefox installiert"
fi

# 7. Discord Installation (via Flatpak - ist in Pop!_OS bereits aktiviert)
log "Installiere Discord..."
if ! flatpak list | grep -q "com.discordapp.Discord"; then
    flatpak install -y flathub com.discordapp.Discord
    success "Discord installiert"
else
    warning "Discord ist bereits installiert"
fi

# 8. Steam Installation
log "Installiere Steam..."
if ! command -v steam &> /dev/null; then
    # Steam über apt installieren
    sudo apt install -y steam-installer
    success "Steam installiert"
else
    warning "Steam ist bereits installiert"
fi

# 9. Gaming Tools
log "Installiere zusätzliche Gaming Tools..."
sudo apt install -y lutris gamemode mangohud
success "Lutris, GameMode und MangoHud installiert"

echo ""
echo "=================================="
echo "Phase 5: System-Tools"
echo "=================================="

# 10. Deja Dup (Backups)
log "Installiere Deja Dup..."
if ! command -v deja-dup &> /dev/null; then
    sudo apt install -y deja-dup
    success "Deja Dup installiert"
else
    warning "Deja Dup ist bereits installiert"
fi

# 11. Tailscale Installation
log "Installiere Tailscale..."
if ! command -v tailscale &> /dev/null; then
    log "Lade Tailscale Installationsscript..."
    curl -fsSL https://tailscale.com/install.sh | sh
    success "Tailscale installiert"
    log "Führe 'sudo tailscale up' aus, um Tailscale zu aktivieren"
else
    warning "Tailscale ist bereits installiert"
fi

# 12. Weitere nützliche Tools
log "Installiere weitere Tools..."
# Nur die Tools installieren, die noch fehlen könnten
sudo apt install -y htop tree
success "Zusätzliche Tools installiert"

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
echo "6. Steam: Aktiviere Proton in den Steam-Einstellungen"
echo "7. Lutris: Konfiguriere für Non-Steam Games"
echo ""
warning "WICHTIG: Nach dem Neustart läuft Zsh als Standard-Shell!"
echo ""
echo "Gaming-Tipps:"
echo "- MangoHud für FPS-Overlay: mangohud %command% in Steam Launch Options"
echo "- GameMode wird automatisch von Steam verwendet"
echo "- Lutris für Epic Games, GOG, etc."
