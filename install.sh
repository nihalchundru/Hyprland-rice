#!/usr/bin/env bash
# =============================================================================
# astra-dots install.sh
# Arch Linux ARM (aarch64) — ALARM
# =============================================================================

set -e

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   astra-dots installer                        ║"
echo "║   Arch Linux ARM (ALARM)                      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# =============================================================================
# STEP 1 — System update
# =============================================================================
echo "[1/9] Updating system..."
sudo pacman -Syu --noconfirm

# =============================================================================
# STEP 2 — Base packages (pacman)
# =============================================================================
echo "[2/9] Installing base packages..."
sudo pacman -S --noconfirm --needed \
    base-devel git curl wget \
    hyprland hyprlock hypridle hyprpicker hyprsunset \
    xdg-desktop-portal-hyprland \
    wayland wayland-protocols wlroots \
    wl-clipboard xorg-xwayland \
    kitty fish \
    pipewire pipewire-pulse pipewire-alsa pipewire-jack \
    wireplumber pavucontrol \
    awww mpvpaper \
    swaync \
    cliphist \
    playerctl \
    brightnessctl \
    networkmanager network-manager-applet nm-connection-editor \
    bluez bluez-utils \
    grim slurp \
    ttf-jetbrains-mono-nerd \
    ttf-fira-code \
    ttf-fira-sans \
    ttf-cascadia-code-nerd \
    ttf-hack-nerd \
    ttf-nerd-fonts-symbols \
    ttf-nerd-fonts-symbols-mono \
    noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-liberation \
    ttf-roboto \
    ttf-opensans \
    adobe-source-code-pro-fonts \
    python python-pip \
    polkit-kde-agent \
    thunar \
    imagemagick \
    btop \
    qt6-base qt6-declarative \
    rofi-wayland \
    jq bc \
    xdg-utils \
    libnotify \
    upower \
    acpi \
    wmctrl \
    python-pillow

echo "[✓] Base packages installed"

# =============================================================================
# STEP 3 — Rust
# =============================================================================
echo "[3/9] Installing Rust..."
if ! command -v rustc &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "[✓] Rust installed"
else
    echo "[✓] Rust already installed"
fi

# =============================================================================
# STEP 4 — AUR helper (paru)
# =============================================================================
echo "[4/9] Installing paru..."
if ! command -v paru &>/dev/null; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
    echo "[✓] paru installed"
else
    echo "[✓] paru already installed"
fi

# =============================================================================
# STEP 5 — AUR packages
# =============================================================================
echo "[5/9] Installing AUR packages..."
paru -S --noconfirm --needed \
    quickshell-git \
    hyprshot \
    zen-browser-bin \
    matugen-bin \
    snappy-switcher \
    adw-gtk3 \
    ttf-inter \
    ttf-material-design-icons-extended \
    wlogout

echo "[✓] AUR packages installed"

# =============================================================================
# STEP 6 — Cargo packages
# =============================================================================
echo "[6/9] Installing cargo packages..."
source "$HOME/.cargo/env" 2>/dev/null || true
cargo install lutgen-studio
echo "[✓] Cargo packages installed"

# =============================================================================
# STEP 7 — SF Pro Fonts
# =============================================================================
echo "[7/9] Installing SF Pro Fonts..."
git clone https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts /tmp/sf-fonts
cd /tmp/sf-fonts
mkdir -p ~/.local/share/fonts/SF-Pro
cp *.otf *.ttf ~/.local/share/fonts/SF-Pro/ 2>/dev/null || true
cd -
echo "[✓] SF Pro Fonts installed"

# =============================================================================
# STEP 8 — Iris
# =============================================================================
echo "[8/9] Installing iris..."
if ! command -v iris &>/dev/null; then
    git clone https://github.com/Harman1307/iris /tmp/iris
    cd /tmp/iris
    pip install . --break-system-packages
    cd -
    echo "[✓] Iris installed"
else
    echo "[✓] Iris already installed"
fi

# =============================================================================
# STEP 9 — Copy configs
# =============================================================================
echo "[9/9] Copying configs..."

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Backup existing configs
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP"
for dir in hypr quickshell kitty rofi swaync; do
    [ -d "$HOME/.config/$dir" ] && \
        cp -r "$HOME/.config/$dir" "$BACKUP/$dir" 2>/dev/null || true
done
echo "[✓] Existing configs backed up to $BACKUP"

# Copy new configs
cp -r "$DOTS/.config/"* "$HOME/.config/"
echo "[✓] Configs copied to ~/.config/"

# =============================================================================
# Post-install
# =============================================================================

# Fish as default shell
if ! grep -q "$(which fish)" /etc/shells; then
    echo "$(which fish)" | sudo tee -a /etc/shells
fi
chsh -s "$(which fish)"
echo "[✓] Fish set as default shell"

# Enable services
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
systemctl --user enable --now pipewire
systemctl --user enable --now pipewire-pulse
systemctl --user enable --now wireplumber
echo "[✓] Services enabled"

# Refresh font cache after all fonts installed
mkdir -p ~/.local/share/fonts
fc-cache -fv
echo "[✓] Font cache refreshed"

# Wallpaper directories
mkdir -p ~/.config/hypr/wallpapers/{catppuccin,tokyonight,gruvbox,gruvbox-material,nord,rosepine,everforest,onedark,astrabloom,crimson,solarized,iris,matugen,custom}
echo "[✓] Wallpaper directories created"

# awww cache
mkdir -p ~/.cache/awww
touch ~/.cache/awww/.init
echo "[✓] awww cache directory created"

# Quickshell cache
mkdir -p ~/.cache/quickshell/wallpaper_picker
echo "[✓] Quickshell cache created"

# Overview tmp dir
mkdir -p /tmp/hyde-overview
echo "[✓] Overview tmp dir created"

# Hyprland assets dir
mkdir -p ~/.config/hypr/assets
echo "[✓] Hyprland assets dir created"

# Bar state dir
mkdir -p ~/.config/hypr/bar
echo "[✓] Bar state dir created"

# Initial state files
echo "quickshell" > ~/.config/hypr/bar/active-bar
echo "pill"       > ~/.config/hypr/bar/qs-layout
echo "12"         > ~/.config/hypr/themes/clock-format
echo "grow"       > ~/.config/hypr/themes/wall-transition
echo "1.8"        > ~/.config/hypr/themes/wall-transition-duration
echo "off"        > ~/.config/hypr/themes/night-shift-state
echo "hyprlock"   > ~/.config/hypr/active-lockscreen
echo "catppuccin" > ~/.config/hypr/themes/current-name
echo "[✓] Initial state files written"

# Initialize awww daemon
awww init &
sleep 1
echo "[✓] awww daemon initialized"

# Placeholder wallpaper files
mkdir -p ~/.config/rofi/images
touch ~/.config/hypr/assets/current_wallpaper.png
touch ~/.config/rofi/images/a.png
touch ~/.config/rofi/images/d.png
touch ~/.config/rofi/images/f.png
cat > ~/.config/rofi/current_wallpaper.rasi << 'RASI'
* { current-image: url("~/.config/rofi/images/a.png", width); }
RASI
echo "[✓] Placeholder wallpaper files created"

# Iris + matugen cache dirs
mkdir -p ~/.cache/iris
mkdir -p ~/.cache/matugen
echo "[✓] Iris and matugen cache dirs created"

# Screenshots directory
mkdir -p ~/Pictures/Screenshots
echo "[✓] Screenshots directory created"

# Initial theme
bash ~/.config/hypr/scripts/write-colors.sh catppuccin
echo "[✓] Initial theme applied (catppuccin)"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   Installation complete! 🌌                   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Add wallpapers to ~/.config/hypr/wallpapers/<theme>/"
echo "  Log out and select Hyprland from your display manager"
echo "  or run: Hyprland"
echo ""
echo "  First boot keybinds:"
echo "  ALT + D         → App launcher"
echo "  ALT + T         → Theme switcher"
echo "  ALT + W         → Wallpaper switcher"
echo "  ALT + SHIFT + A → Settings"
echo ""
