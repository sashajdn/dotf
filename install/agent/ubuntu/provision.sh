#!/bin/bash
#
# Ubuntu Agent Provisioning Script
# Full setup for a fresh Ubuntu server (22.04 LTS)
#
# Usage: curl -fsSL <raw-url> | sudo bash
#    or: sudo ./provision.sh [username]
#
# Run as root on a fresh machine. Creates agent user, installs
# packages, hardens SSH, sets up Docker, Node, zsh, etc.
#

set -e

# --- Config ---
USERNAME="${1:-clank}"
DOTF_REPO="https://github.com/sashajdn/dotf.git"
DOTF_DIR="/home/$USERNAME/dotf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}🤖 $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# --- Preflight ---
[[ $EUID -ne 0 ]] && error "Run as root: sudo $0"
[[ ! -f /etc/os-release ]] && error "Cannot detect OS"
source /etc/os-release
[[ "$ID" != "ubuntu" ]] && error "This script is for Ubuntu only (got: $ID)"

log "Starting Ubuntu agent provisioning..."
log "Username: $USERNAME"

# --- System Update ---
log "Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

# --- Essential Packages ---
log "Installing essential packages..."
apt-get install -y -qq \
    curl \
    wget \
    git \
    htop \
    tmux \
    zsh \
    zsh-syntax-highlighting \
    jq \
    unzip \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common

# --- Create User ---
if id "$USERNAME" &>/dev/null; then
    warn "User $USERNAME already exists, skipping creation"
else
    log "Creating user: $USERNAME"
    useradd -m -s /bin/zsh "$USERNAME"
    usermod -aG sudo "$USERNAME"
    
    # Passwordless sudo
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
    chmod 440 "/etc/sudoers.d/$USERNAME"
    
    # Copy SSH keys from root
    if [[ -f ~/.ssh/authorized_keys ]]; then
        mkdir -p "/home/$USERNAME/.ssh"
        cp ~/.ssh/authorized_keys "/home/$USERNAME/.ssh/"
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
        chmod 700 "/home/$USERNAME/.ssh"
        chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
        log "SSH keys copied from root"
    else
        warn "No root SSH keys found - add keys manually"
    fi
fi

# --- Docker ---
if command -v docker &>/dev/null; then
    warn "Docker already installed, skipping"
else
    log "Installing Docker..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Add user to docker group
usermod -aG docker "$USERNAME" 2>/dev/null || true

# --- Node.js (via NodeSource) ---
if command -v node &>/dev/null; then
    warn "Node.js already installed: $(node -v)"
else
    log "Installing Node.js 22.x..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y -qq nodejs
fi

# --- GitHub CLI ---
if command -v gh &>/dev/null; then
    warn "GitHub CLI already installed"
else
    log "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    apt-get update -qq
    apt-get install -y -qq gh
fi

# --- Tailscale ---
if command -v tailscale &>/dev/null; then
    warn "Tailscale already installed"
else
    log "Installing Tailscale..."
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).noarmor.gpg | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).tailscale-keyring.list | tee /etc/apt/sources.list.d/tailscale.list
    apt-get update -qq
    apt-get install -y -qq tailscale
fi

# --- Powerlevel10k ---
P10K_DIR="/usr/share/powerlevel10k"
if [[ -d "$P10K_DIR" ]]; then
    warn "Powerlevel10k already installed"
else
    log "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# --- Dotfiles ---
if [[ -d "$DOTF_DIR" ]]; then
    warn "Dotfiles already present at $DOTF_DIR"
else
    log "Cloning dotfiles..."
    sudo -u "$USERNAME" git clone "$DOTF_REPO" "$DOTF_DIR"
fi

# --- Symlinks ---
log "Creating symlinks..."
sudo -u "$USERNAME" mkdir -p "/home/$USERNAME/.config" "/home/$USERNAME/.cache/zsh"

# Zsh
sudo -u "$USERNAME" ln -sf "$DOTF_DIR/zsh/zshrc" "/home/$USERNAME/.zshrc"
[[ -f "$DOTF_DIR/zsh/p10k.zsh" ]] && sudo -u "$USERNAME" ln -sf "$DOTF_DIR/zsh/p10k.zsh" "/home/$USERNAME/.p10k.zsh"

# Neovim (if exists)
[[ -d "$DOTF_DIR/nvim" ]] && sudo -u "$USERNAME" ln -sf "$DOTF_DIR/nvim" "/home/$USERNAME/.config/nvim"

# Tmux (if exists)
[[ -d "$DOTF_DIR/tmux" ]] && sudo -u "$USERNAME" ln -sf "$DOTF_DIR/tmux" "/home/$USERNAME/.config/tmux"

# --- UFW Firewall ---
log "Configuring firewall..."
apt-get install -y -qq ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw --force enable

# --- Fail2ban ---
log "Configuring fail2ban..."
apt-get install -y -qq fail2ban
cat > /etc/fail2ban/jail.local << 'EOF'
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
findtime = 600
EOF
systemctl enable fail2ban
systemctl restart fail2ban

# --- SSH Hardening ---
log "Hardening SSH..."
SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak.$(date +%s)"

# Apply hardening (only if not already set)
grep -q "^PermitRootLogin no" "$SSHD_CONFIG" || echo "PermitRootLogin no" >> "$SSHD_CONFIG"
grep -q "^PasswordAuthentication no" "$SSHD_CONFIG" || echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
grep -q "^PubkeyAuthentication yes" "$SSHD_CONFIG" || echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
grep -q "^X11Forwarding no" "$SSHD_CONFIG" || echo "X11Forwarding no" >> "$SSHD_CONFIG"
grep -q "^MaxAuthTries 3" "$SSHD_CONFIG" || echo "MaxAuthTries 3" >> "$SSHD_CONFIG"

# Validate config before restart
sshd -t && systemctl restart sshd

# --- Summary ---
echo ""
log "═══════════════════════════════════════════════════════"
log "  Provisioning complete!"
log "═══════════════════════════════════════════════════════"
echo ""
echo "  User:     $USERNAME"
echo "  Shell:    /bin/zsh"
echo "  Dotfiles: $DOTF_DIR"
echo ""
echo "  Installed:"
echo "    • Docker $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')"
echo "    • Node $(node --version 2>/dev/null)"
echo "    • GitHub CLI $(gh --version 2>/dev/null | head -1 | awk '{print $3}')"
echo "    • Tailscale (run: sudo tailscale up)"
echo "    • zsh + Powerlevel10k"
echo "    • tmux"
echo ""
echo "  Security:"
echo "    • UFW enabled (22, 80, 443)"
echo "    • fail2ban active"
echo "    • SSH hardened (key-only, no root)"
echo ""
log "  ⚠️  Test SSH access before disconnecting!"
log "  ssh $USERNAME@$(hostname -I | awk '{print $1}')"
echo ""
