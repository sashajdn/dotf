#!/bin/bash
#
# OpenClaw Setup Script
# Installs and configures OpenClaw on an already-provisioned machine
#
# Usage: ./openclaw.sh
#
# Prerequisites: Node.js 22+, npm
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}🤖 $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

# --- Preflight ---
command -v node &>/dev/null || error "Node.js not found. Run provision.sh first."
command -v npm &>/dev/null || error "npm not found. Run provision.sh first."

NODE_MAJOR=$(node -v | cut -d'.' -f1 | tr -d 'v')
[[ $NODE_MAJOR -lt 22 ]] && error "Node.js 22+ required (got: $(node -v))"

log "Installing OpenClaw..."

# --- Install OpenClaw ---
npm install -g openclaw

# --- Create workspace ---
WORKSPACE="$HOME/.openclaw/workspace"
mkdir -p "$WORKSPACE"

# --- Config directory ---
mkdir -p "$HOME/.openclaw"

# --- Verify ---
if command -v openclaw &>/dev/null; then
    log "OpenClaw installed: $(openclaw --version 2>/dev/null || echo 'unknown version')"
else
    error "OpenClaw installation failed"
fi

# --- Summary ---
echo ""
log "═══════════════════════════════════════════════════════"
log "  OpenClaw installed!"
log "═══════════════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Create config file:"
echo "     openclaw init"
echo ""
echo "  2. Add your API keys to ~/.openclaw/config.yaml"
echo ""
echo "  3. Start the gateway:"
echo "     openclaw gateway start"
echo ""
echo "  4. (Optional) Set up as systemd service:"
echo "     openclaw gateway install"
echo ""
