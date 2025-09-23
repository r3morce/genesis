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
echo "NVIDIA-Tipps:"
echo "- Nach Neustart: nvidia-settings für GPU-Konfiguration"
echo "- Treiber-Status prüfen: nvidia-smi"
echo "- Steam: NVIDIA GPU wird automatisch erkannt"
echo "=================================="
echo "Phase 1: NVIDIA-Treiber & System"
echo "=================================="

# 1. NVIDIA-Treiber Installation/Update
log "Installiere/Update NVIDIA-Treiber..."
if lspci | grep -i nvidia &> /dev/null; then
    log "NVIDIA-GPU erkannt, installiere Treiber..."
    
    # NVIDIA Repository hinzufügen
    if ! zypper lr | grep -q nvidia; then
        sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
        success "NVIDIA Repository hinzugefügt"
    fi
    
    # Proprietary NVIDIA Treiber installieren
    sudo zypper install -y nvidia-driver-G06 nvidia-settings nvidia-compute-utils
    
    # 32-bit Bibliotheken für Steam/Gaming
    sudo zypper install -y nvidia-driver-G06-32bit
    
    success "NVIDIA-Treiber installiert"
    warning "NEUSTART ERFORDERLICH nach Script-Ende für NVIDIA-Treiber!"
else
    warning "Keine NVIDIA-GPU gefunden, überspringe NVIDIA-Treiber"
fi

echo ""
echo "=================================="
echo "Phase 2: System-Grundlagen & Repos"
echo "=================================="

# 2. Basis-Tools und Repositories
log "Installiere Basis-Tools..."
sudo zypper install -y curl wget git

# Flatpak Repository hinzufügen (für Discord etc.)
log "Richte Flatpak ein..."
if ! command -v flatpak &> /dev/null; then
    sudo zypper install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    success "Flatpak eingerichtet"
else
    warning "Flatpak ist bereits installiert"
fi

# Steam Repository hinzufügen
log "Füge Steam Repository hinzu..."
if ! zypper lr | grep -q games; then
    sudo zypper addrepo -f https://download.opensuse.org/repositories/games/openSUSE_Tumbleweed/ games
    sudo zypper refresh
    success "Steam Repository hinzugefügt"
else
    warning "Steam Repository bereits vorhanden"
fi

echo ""
echo "=================================="
echo "Phase 3: Shell & Terminal"
echo "=================================="

# 3. Zsh Installation
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

# 4. P10k Installation
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
echo "Phase 4: Daten-Synchronisation"
echo "=================================="

# 5. Syncthing Installation
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

# 6. KeepassXC Installation
log "Installiere KeepassXC..."
if ! command -v keepassxc &> /dev/null; then
    sudo zypper install -y keepassxc
    success "KeepassXC installiert"
else
    warning "KeepassXC ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Phase 5: Entwicklungstools"
echo "=================================="

# 7. Build-Tools und Entwicklung
log "Installiere Entwicklungstools..."
sudo zypper install -y \
    gcc \
    make \
    cmake \
    git \
    vim \
    neovim \
    patterns-devel-base-devel_basis
success "Entwicklungstools installiert"

# 8. LazyVim Setup
if [ ! -d "$HOME/.config/nvim" ]; then
    log "Installiere LazyVim..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    success "LazyVim installiert"
else
    warning "Neovim Konfiguration existiert bereits"
fi

echo ""
echo "=================================="
echo "Phase 6: Desktop-Anwendungen"
echo "=================================="

# 9. Firefox (sollte vorinstalliert sein)
log "Firefox prüfen..."
if command -v firefox &> /dev/null; then
    success "Firefox ist bereits installiert"
else
    sudo zypper install -y firefox
    success "Firefox installiert"
fi

# 10. LibreOffice (meist vorinstalliert)
log "LibreOffice prüfen..."
if command -v libreoffice &> /dev/null; then
    success "LibreOffice ist bereits installiert"
else
    sudo zypper install -y libreoffice
    success "LibreOffice installiert"
fi

# 11. Discord Installation (via Flatpak)
log "Installiere Discord..."
if ! flatpak list | grep -q "com.discordapp.Discord"; then
    flatpak install -y flathub com.discordapp.Discord
    success "Discord installiert"
else
    warning "Discord ist bereits installiert"
fi

echo ""
echo "=================================="
echo "Phase 7: Gaming"
echo "=================================="

# 12. Steam Installation
log "Installiere Steam..."
if ! command -v steam &> /dev/null; then
    sudo zypper install -y steam steam-devices
    success "Steam installiert"
else
    warning "Steam ist bereits installiert"
fi

# 13. Gaming Tools
log "Installiere Gaming-Tools..."
sudo zypper install -y lutris
success "Lutris installiert"

# MangoHud für FPS-Overlay (falls verfügbar)
if zypper search mangohud | grep -q mangohud; then
    sudo zypper install -y mangohud
    success "MangoHud installiert"
else
    warning "MangoHud nicht in Repositories gefunden"
fi

echo ""
echo "=================================="
echo "Phase 8: System-Tools"
echo "=================================="

# 14. System-Monitoring
log "Installiere System-Tools..."
sudo zypper install -y \
    htop \
    tree \
    unzip \
    curl \
    wget
success "System-Tools installiert"

# 15. Backup-Tool
log "Installiere Backup-Tools..."
if ! command -v deja-dup &> /dev/null; then
    # Deja Dup falls verfügbar, sonst Alternativen
    if zypper search deja-dup | grep -q deja-dup; then
        sudo zypper install -y deja-dup
        success "Deja Dup installiert"
    else
        sudo zypper install -y rsync
        success "Rsync installiert (für Backups)"
    fi
else
    warning "Backup-Tool ist bereits installiert"
fi

# 16. Tailscale Installation
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
echo "6. Steam: Aktiviere Proton in den Steam-Einstellungen"
echo "7. Lutris: Konfiguriere für Non-Steam Games"
echo ""
warning "WICHTIG: Nach dem Neustart läuft Zsh als Standard-Shell!"
echo ""
echo "Gaming-Tipps:"
echo "- Steam Proton: Settings → Steam Play → Enable Proton for all titles"
echo "- MangoHud (falls installiert): mangohud %command% in Steam Launch Options"
echo "- Lutris für Epic Games, GOG, etc."
echo ""
echo "openSUSE-spezifische Tipps:"
echo "- YaST für System-Konfiguration: sudo yast2"
echo "- Zypper Pakete suchen: zypper search PAKETNAME"
echo "- Software-Verwaltung: YaST → Software-Verwaltung"
