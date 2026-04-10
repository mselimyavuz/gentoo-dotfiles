#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
DOTFILES_DIR="$HOME/gentoo-dotfiles"

# Safety Check
if [ -z "$HOME" ] || [ -z "$DOTFILES_DIR" ]; then
    echo -e "\033[0;31mERROR: HOME or DOTFILES_DIR is not set. Exiting.\033[0m"
    exit 1
fi

# Gentoo Package List (Updated based on folder structure)
PACKAGES=(
    "app-shells/zsh"
    "app-misc/tmux"
    "gui-wm/swayfx"
    "gui-apps/waybar"
    "gui-apps/mako"
    "media-video/mpv"
    "app-shells/starship"
    "sys-process/btop"
    "app-misc/fastfetch"
    "gui-apps/foot"
    "app-editors/neovim"
    "app-admin/s-tui"
    "sys-fs/gdu"
    "games-misc/fortune-mod"
    "app-text/zathura"
    "app-text/zathura-pdf-mupdf"
    "app-misc/ranger"
    "mail-client/aerc"
    "app-misc/urlview-ng"
)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}::: Starting Gentoo Dotfiles Setup :::${NC}"

# ==========================================
# 0. DISTRO CHECK
# ==========================================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" == "gentoo" || "$ID_LIKE" == *"gentoo"* ]]; then
        echo -e "${GREEN}✓ Detected Gentoo system.${NC}"
    else
        echo -e "${RED}ERROR: This script is intended for Gentoo systems.${NC}"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 1; fi
    fi
fi

# ==========================================
# 1. CORE TOOLS CHECK
# ==========================================
echo -e "\n${BLUE}[1/5] Checking Core Tools...${NC}"
# Ensure equery and qlist are available for the script's own logic
for tool in "app-portage/portage-utils:qlist" "app-portage/gentoolkit:equery" "app-eselect/eselect-repository:eselect repository"; do
    PKG=${tool%%:*}
    CMD=${tool#*:}
    if ! command -v ${CMD%% *} &> /dev/null; then
        echo -e "${YELLOW}$PKG not found. Installing...${NC}"
        sudo emerge -n "$PKG"
    fi
done

# ==========================================
# 2. REPO CHECK (GURU)
# ==========================================
echo -e "\n${BLUE}[2/5] Checking GURU Overlay...${NC}"
if eselect repository list -i | grep -qE "\s+guru\s+"; then
    echo -e "${GREEN}✓ GURU overlay active.${NC}"
else
    sudo eselect repository enable guru
    sudo emaint sync -r guru
fi

# ==========================================
# 3. PACKAGE INSTALLATION
# ==========================================
echo -e "\n${BLUE}[3/5] Checking System Packages...${NC}"
PACKAGES_TO_INSTALL=()
for pkg in "${PACKAGES[@]}"; do
    if qlist -IC "$pkg" > /dev/null; then
        echo -e "${GREEN}✓ $pkg is installed.${NC}"
    else
        PACKAGES_TO_INSTALL+=("$pkg")
    fi
done

if [ ${#PACKAGES_TO_INSTALL[@]} -ne 0 ]; then
    sudo emerge --noreplace --ask --verbose "${PACKAGES_TO_INSTALL[@]}"
fi

# ==========================================
# 4. CLEANUP ROUTINE (Matches current structure)
# ==========================================
echo -e "\n${BLUE}[4/5] Cleaning old configurations...${NC}"
REMOVE_LIST=(
    "$HOME/.profile" "$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.tmux"
    "$HOME/.config/btop" "$HOME/.config/fastfetch" "$HOME/.config/foot"
    "$HOME/.config/mako" "$HOME/.config/mpv" "$HOME/.config/nvim"
    "$HOME/.config/sway" "$HOME/.config/waybar" "$HOME/.config/starship.toml"
    "$HOME/.config/ranger" "$HOME/.config/aerc" "$HOME/.config/termusic"
    "$HOME/.config/euporie" "$HOME/.config/zathura"
    "$HOME/.local/bin/portage-cleaner.py"
    "$HOME/mail-sync.sh" "$HOME/.urlview"
)

for item in "${REMOVE_LIST[@]}"; do
    if [ -e "$item" ] || [ -h "$item" ]; then
        rm -rf "$item"
        echo -e "${RED}Deleted:${NC} $item"
    fi
done

# ==========================================
# 5. LINKING ROUTINE
# ==========================================
echo -e "\n${BLUE}[5/5] Linking new configurations...${NC}"
link_config() {
    local src="$1"
    local dest="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -s "$src" "$dest"
        echo -e "${GREEN}Linked:${NC} $dest -> $src"
    else
        echo -e "${YELLOW}Warning:${NC} Source $src not found. Skipping."
    fi
}

# Home-level Files
link_config "$DOTFILES_DIR/.profile" "$HOME/.profile"
link_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_config "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link_config "$DOTFILES_DIR/.tmux" "$HOME/.tmux"
link_config "$DOTFILES_DIR/mail-sync.sh" "$HOME/mail-sync.sh"
link_config "$DOTFILES_DIR/.urlview" "$HOME/.urlview"

# Scripts (linking specific known scripts to ~/.local/bin)
link_config "$DOTFILES_DIR/scripts/portage-cleaner.py" "$HOME/.local/bin/portage-cleaner.py"

# .config Directories/Files
CONFIGS=(
    "aerc" "btop" "euporie" "fastfetch" "foot" "mako" 
    "mpv" "nvim" "ranger" "sway" "termusic" "waybar" 
    "zathura" "starship.toml"
)

for cfg in "${CONFIGS[@]}"; do
    link_config "$DOTFILES_DIR/$cfg" "$HOME/.config/$cfg"
done

# ==========================================
# 6. POST-INSTALL & PERMISSIONS
# ==========================================
# Tmux Plugin Manager
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo -e "\n${BLUE}Installing TPM...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Ensure scripts in the dotfiles dir are executable
find "$DOTFILES_DIR/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null
find "$DOTFILES_DIR/scripts" -type f -name "*.py" -exec chmod +x {} + 2>/dev/null
[ -f "$DOTFILES_DIR/mail-sync.sh" ] && chmod +x "$DOTFILES_DIR/mail-sync.sh"

echo -e "\n${GREEN}::: Setup Complete! :::${NC}"

