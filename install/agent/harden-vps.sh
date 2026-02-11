#!/usr/bin/env bash
# =============================================================================
# VPS Hardening Script
# =============================================================================
# Hardens a fresh VPS for Tailscale-only access. Run as root or with sudo.
#
# What it does:
#   1. Configures UFW (SSH + Tailscale only)
#   2. Disables Docker's iptables bypass
#   3. Binds all Docker ports to localhost
#   4. Enables Tailscale SSH (optional, closes port 22)
#   5. Hardens SSH config
#   6. Installs fail2ban
#   7. Enables unattended security upgrades
#   8. Validates everything
#
# Prerequisites:
#   - Tailscale installed and authenticated
#   - Docker installed
#   - SSH key access configured (password auth will be disabled)
#
# Usage:
#   sudo bash harden-vps.sh [--tailscale-ssh] [--dry-run]
#
# Flags:
#   --tailscale-ssh   Enable Tailscale SSH and close port 22 entirely
#   --dry-run         Print what would be done without making changes
# =============================================================================

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly NC='\033[0m'

TAILSCALE_SSH=false
DRY_RUN=false

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log()  { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
err()  { echo -e "${RED}[✗]${NC} $*" >&2; }
fatal(){ err "$*"; exit 1; }

run() {
    if $DRY_RUN; then
        echo -e "${YELLOW}[dry-run]${NC} $*"
    else
        eval "$@"
    fi
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------

preflight() {
    log "Running pre-flight checks..."

    # Must be root or sudo
    if [[ $EUID -ne 0 ]]; then
        fatal "This script must be run as root (or with sudo)"
    fi

    # Tailscale must be up
    if ! tailscale status &>/dev/null; then
        fatal "Tailscale is not running. Install and authenticate first."
    fi
    local ts_ip
    ts_ip=$(tailscale ip -4 2>/dev/null || true)
    if [[ -z "$ts_ip" ]]; then
        fatal "Cannot determine Tailscale IP. Is Tailscale authenticated?"
    fi
    log "Tailscale IP: $ts_ip"

    # Docker must be installed
    if ! command -v docker &>/dev/null; then
        warn "Docker not installed — skipping Docker hardening steps"
    fi

    # SSH key access should be configured
    if [[ ! -f /root/.ssh/authorized_keys ]] && [[ ! -f /home/*/.ssh/authorized_keys ]]; then
        warn "No SSH authorized_keys found. Make sure key auth works before proceeding!"
        read -rp "Continue anyway? [y/N] " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
    fi

    log "Pre-flight checks passed"
}

# ---------------------------------------------------------------------------
# Step 1: UFW Configuration
# ---------------------------------------------------------------------------

configure_ufw() {
    log "Configuring UFW..."

    if ! command -v ufw &>/dev/null; then
        run "apt-get update -qq && apt-get install -y -qq ufw"
    fi

    # Reset to clean state
    run "ufw --force reset"

    # Default policies
    run "ufw default deny incoming"
    run "ufw default allow outgoing"
    run "ufw default deny routed"

    # SSH (rate limited) — unless using Tailscale SSH exclusively
    if ! $TAILSCALE_SSH; then
        run "ufw limit 22/tcp comment 'SSH rate-limited'"
        log "SSH allowed on port 22 (rate-limited)"
    else
        log "SSH port 22 will NOT be opened (Tailscale SSH mode)"
    fi

    # Tailscale subnet
    run "ufw allow in on tailscale0 comment 'Tailscale interface'"
    run "ufw allow from 100.64.0.0/10 comment 'Tailscale CGNAT range'"

    # Enable
    run "ufw --force enable"
    log "UFW configured and enabled"
}

# ---------------------------------------------------------------------------
# Step 2: Docker iptables bypass
# ---------------------------------------------------------------------------

configure_docker() {
    if ! command -v docker &>/dev/null; then
        warn "Docker not found, skipping"
        return
    fi

    log "Configuring Docker to not bypass firewall..."

    local daemon_json="/etc/docker/daemon.json"

    if [[ -f "$daemon_json" ]]; then
        # Check if iptables is already set
        if grep -q '"iptables": false' "$daemon_json"; then
            log "Docker iptables bypass already disabled"
        else
            warn "Existing $daemon_json found — merging iptables:false"
            # Use python/jq to merge if available, else warn
            if command -v jq &>/dev/null; then
                run "jq '. + {\"iptables\": false}' $daemon_json > /tmp/daemon.json.tmp && mv /tmp/daemon.json.tmp $daemon_json"
            else
                warn "No jq available. Manually add '\"iptables\": false' to $daemon_json"
                return
            fi
        fi
    else
        run "echo '{\"iptables\": false}' > $daemon_json"
    fi

    # Add NAT masquerade for Docker bridge networks
    # Without Docker managing iptables, containers need this for outbound internet
    local iface
    iface=$(ip route | grep default | awk '{print $5}' | head -1)
    if [[ -n "$iface" ]]; then
        run "iptables -t nat -C POSTROUTING -s 172.16.0.0/12 -o $iface -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -o $iface -j MASQUERADE"
        run "iptables -t nat -C POSTROUTING -s 192.168.0.0/16 -o $iface -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 192.168.0.0/16 -o $iface -j MASQUERADE"
        log "NAT masquerade added for Docker on $iface"
    fi

    # Persist iptables
    run "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iptables-persistent"
    run "netfilter-persistent save"

    log "Docker firewall bypass disabled"
    warn "Docker restart required — run: systemctl restart docker"
}

# ---------------------------------------------------------------------------
# Step 3: SSH Hardening
# ---------------------------------------------------------------------------

harden_ssh() {
    log "Hardening SSH..."

    local sshd_config="/etc/ssh/sshd_config"

    # Backup
    run "cp $sshd_config ${sshd_config}.bak.$(date +%s)"

    # Apply hardening
    local settings=(
        "PermitRootLogin no"
        "PasswordAuthentication no"
        "PubkeyAuthentication yes"
        "X11Forwarding no"
        "MaxAuthTries 3"
        "ClientAliveInterval 300"
        "ClientAliveCountMax 2"
    )

    for setting in "${settings[@]}"; do
        local key="${setting%% *}"
        if grep -q "^${key}" "$sshd_config"; then
            run "sed -i 's/^${key}.*/${setting}/' $sshd_config"
        elif grep -q "^#${key}" "$sshd_config"; then
            run "sed -i 's/^#${key}.*/${setting}/' $sshd_config"
        else
            run "echo '${setting}' >> $sshd_config"
        fi
    done

    run "systemctl reload sshd"
    log "SSH hardened (key-only, no root, no password)"
}

# ---------------------------------------------------------------------------
# Step 4: Tailscale SSH (optional)
# ---------------------------------------------------------------------------

configure_tailscale_ssh() {
    if ! $TAILSCALE_SSH; then
        warn "Skipping Tailscale SSH (use --tailscale-ssh to enable)"
        return
    fi

    log "Enabling Tailscale SSH..."

    # Enable Tailscale SSH
    run "tailscale set --ssh"

    # Test connectivity before closing port 22
    warn "IMPORTANT: Test Tailscale SSH access before closing port 22!"
    warn "  From another machine: ssh <tailscale-hostname>"
    warn "  If it works, port 22 is no longer needed."

    if ! $DRY_RUN; then
        read -rp "Has Tailscale SSH been verified? Close port 22? [y/N] " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            ufw delete limit 22/tcp 2>/dev/null || true
            ufw delete allow 22/tcp 2>/dev/null || true
            log "Port 22 closed. SSH only via Tailscale now."
        else
            warn "Port 22 left open. Close manually with: ufw delete limit 22/tcp"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Step 5: Fail2ban
# ---------------------------------------------------------------------------

install_fail2ban() {
    log "Installing fail2ban..."

    if systemctl is-active fail2ban &>/dev/null; then
        log "fail2ban already active"
        return
    fi

    run "apt-get install -y -qq fail2ban"
    run "systemctl enable fail2ban"
    run "systemctl start fail2ban"
    log "fail2ban installed and running"
}

# ---------------------------------------------------------------------------
# Step 6: Unattended upgrades
# ---------------------------------------------------------------------------

configure_auto_updates() {
    log "Configuring unattended security upgrades..."

    run "apt-get install -y -qq unattended-upgrades"
    run "dpkg-reconfigure -plow unattended-upgrades" 2>/dev/null || true
    log "Unattended upgrades configured"
}

# ---------------------------------------------------------------------------
# Step 7: Audit docker-compose files
# ---------------------------------------------------------------------------

audit_docker_compose() {
    log "Auditing Docker Compose files for exposed ports..."

    local found_issues=false
    local compose_files
    compose_files=$(find /home -name "docker-compose.yml" -o -name "docker-compose.yaml" 2>/dev/null)

    for f in $compose_files; do
        # Look for port mappings not bound to 127.0.0.1
        local bad_ports
        bad_ports=$(grep -nE '^\s+- "[0-9]+:[0-9]+"' "$f" 2>/dev/null || true)
        if [[ -n "$bad_ports" ]]; then
            err "EXPOSED PORTS in $f:"
            echo "$bad_ports"
            found_issues=true
        fi
    done

    if $found_issues; then
        err "Found docker-compose files with ports bound to 0.0.0.0!"
        err "Fix: Change '\"PORT:PORT\"' to '\"127.0.0.1:PORT:PORT\"'"
        warn "Quick fix: sed -i 's/- \"\\([0-9]\\)/- \"127.0.0.1:\\1/g' <file>"
    else
        log "All docker-compose port bindings are localhost-only"
    fi
}

# ---------------------------------------------------------------------------
# Step 8: Final validation
# ---------------------------------------------------------------------------

validate() {
    log "Running final validation..."
    local issues=0

    # Check public listeners
    echo ""
    echo "=== Public Listeners (should only be SSH or empty) ==="
    local public_ports
    public_ports=$(ss -tlnp | grep "0.0.0.0" | grep -v "127.0.0" || true)
    if [[ -n "$public_ports" ]]; then
        if $TAILSCALE_SSH; then
            # Should be empty
            if echo "$public_ports" | grep -v ":22 " &>/dev/null; then
                err "Non-SSH ports exposed:"
                echo "$public_ports" | grep -v ":22 "
                ((issues++))
            fi
        else
            # Only SSH should be there
            if echo "$public_ports" | grep -v ":22 " &>/dev/null; then
                err "Non-SSH ports exposed:"
                echo "$public_ports" | grep -v ":22 "
                ((issues++))
            fi
        fi
        echo "$public_ports"
    else
        log "No public listeners"
    fi

    # Check Docker daemon.json
    echo ""
    if [[ -f /etc/docker/daemon.json ]] && grep -q '"iptables": false' /etc/docker/daemon.json; then
        log "Docker iptables bypass: DISABLED ✓"
    else
        err "Docker iptables bypass: NOT DISABLED"
        ((issues++))
    fi

    # Check UFW
    echo ""
    if ufw status | grep -q "Status: active"; then
        log "UFW: ACTIVE ✓"
    else
        err "UFW: INACTIVE"
        ((issues++))
    fi

    # Check SSH config
    echo ""
    if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
        log "SSH password auth: DISABLED ✓"
    else
        err "SSH password auth: ENABLED"
        ((issues++))
    fi

    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
        log "SSH root login: DISABLED ✓"
    else
        err "SSH root login: ENABLED"
        ((issues++))
    fi

    # Check fail2ban
    echo ""
    if systemctl is-active fail2ban &>/dev/null; then
        log "fail2ban: ACTIVE ✓"
    else
        warn "fail2ban: NOT RUNNING"
    fi

    # Docker port bindings
    echo ""
    echo "=== Docker Container Port Bindings ==="
    if command -v docker &>/dev/null; then
        docker ps --format '{{.Names}}: {{.Ports}}' 2>/dev/null | sort
        local bad_docker
        bad_docker=$(docker ps --format '{{.Ports}}' 2>/dev/null | grep "0.0.0.0:" || true)
        if [[ -n "$bad_docker" ]]; then
            err "Docker containers with public port bindings found!"
            ((issues++))
        else
            log "All Docker ports bound to localhost ✓"
        fi
    fi

    # Default credentials check
    echo ""
    echo "=== Default Credential Check ==="
    local compose_creds
    compose_creds=$(grep -rn "PASSWORD=admin\|PASSWORD=postgres\|PASSWORD=root\|PASSWORD=password" /home/*/repos/*/docker-compose.yml 2>/dev/null || true)
    if [[ -n "$compose_creds" ]]; then
        err "Default credentials found:"
        echo "$compose_creds"
        ((issues++))
    else
        log "No default credentials in docker-compose files ✓"
    fi

    echo ""
    echo "==========================================="
    if [[ $issues -eq 0 ]]; then
        log "ALL CHECKS PASSED ✓"
    else
        err "$issues issue(s) found — review and fix above"
    fi
    echo "==========================================="

    return $issues
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    # Parse args
    for arg in "$@"; do
        case "$arg" in
            --tailscale-ssh) TAILSCALE_SSH=true ;;
            --dry-run)       DRY_RUN=true ;;
            -h|--help)
                echo "Usage: sudo $SCRIPT_NAME [--tailscale-ssh] [--dry-run]"
                exit 0
                ;;
            *) fatal "Unknown argument: $arg" ;;
        esac
    done

    echo "==========================================="
    echo "  VPS Hardening Script"
    echo "  $(date -u '+%Y-%m-%d %H:%M UTC')"
    echo "==========================================="
    echo ""

    if $DRY_RUN; then
        warn "DRY RUN MODE — no changes will be made"
        echo ""
    fi

    preflight
    configure_ufw
    configure_docker
    harden_ssh
    configure_tailscale_ssh
    install_fail2ban
    configure_auto_updates
    audit_docker_compose
    validate

    echo ""
    if ! $DRY_RUN; then
        warn "IMPORTANT: Restart Docker to apply iptables changes:"
        warn "  systemctl restart docker"
        warn "  Then bring containers back up:"
        warn "  docker compose up -d"
        echo ""
        warn "Test Tailscale access before disconnecting:"
        warn "  ssh <user>@$(tailscale ip -4)"
    fi
}

main "$@"
