# VPS Hardening Guide

> **Lesson learned Feb 2026:** Docker's `-p` flag publishes to `0.0.0.0` by default, bypassing UFW/iptables entirely. Tailscale is an overlay network — it does NOT firewall the host's public interface. An exposed postgres with default creds was ransomwared within hours.

## The Problem

```
# This looks safe but ISN'T:
ports:
  - "5432:5432"        # Binds to 0.0.0.0 → public internet
  
# Docker also bypasses UFW by inserting its own iptables FORWARD rules.
# UFW shows "deny incoming" but Docker traffic flows anyway.
```

## The Fix

Three layers of defense:

### Layer 1: Docker iptables bypass

```bash
# /etc/docker/daemon.json
{ "iptables": false }

# Restart Docker after:
systemctl restart docker

# Without this, Docker punches holes in UFW regardless of rules.
# You ALSO need NAT masquerade for containers to reach the internet:
iptables -t nat -A POSTROUTING -s 172.16.0.0/12 -o eth0 -j MASQUERADE
```

### Layer 2: Bind all ports to localhost

```yaml
# WRONG (publishes to 0.0.0.0):
ports:
  - "5432:5432"
  - "3000:3000"

# CORRECT (localhost only, access via Tailscale):
ports:
  - "127.0.0.1:5432:5432"
  - "127.0.0.1:3000:3000"
```

**Quick fix for existing docker-compose files:**
```bash
sed -i 's/- "\([0-9]\)/- "127.0.0.1:\1/g' docker-compose.yml
# Fix double-bind if already had some:
sed -i 's/127\.0\.0\.1:127\.0\.0\.1:/127.0.0.1:/g' docker-compose.yml
```

### Layer 3: UFW

```bash
ufw default deny incoming
ufw default allow outgoing
ufw limit 22/tcp                        # SSH rate-limited
ufw allow in on tailscale0              # Tailscale interface
ufw allow from 100.64.0.0/10           # Tailscale CGNAT range
ufw enable
```

## Tailscale SSH (Optional — closes port 22)

Tailscale can handle SSH authentication directly, letting you close port 22 entirely.

### How it works

1. Tailscale SSH runs an SSH server on the Tailscale interface
2. Authentication uses Tailscale identity (your account), not SSH keys
3. ACLs control who can SSH to which machines
4. Port 22 becomes unnecessary

### Setup

```bash
# 1. Enable on the VPS:
tailscale set --ssh

# 2. Test from another Tailscale machine:
ssh user@<tailscale-hostname>
# or
ssh user@<tailscale-ip>

# 3. ONLY after confirming it works, close port 22:
ufw delete limit 22/tcp

# 4. Configure ACLs in Tailscale admin console:
# https://login.tailscale.com/admin/acls
```

### ACL example

```json
{
  "ssh": [
    {
      "action": "accept",
      "src": ["autogroup:owner"],
      "dst": ["autogroup:self"],
      "users": ["root", "clank"]
    }
  ]
}
```

### Risks

- If Tailscale goes down, you lose SSH access entirely
- Mitigate: keep a VPS console/VNC access as emergency backdoor
- Some hosting providers (Hetzner, Vultr) have web-based console access

### Rollback

```bash
# If locked out via Tailscale, use VPS provider console to:
ufw allow 22/tcp
tailscale set --ssh=false
```

## Validation

Run after hardening:

```bash
# Only SSH should be public:
ss -tlnp | grep "0.0.0.0" | grep -v "127.0.0"

# All Docker ports should be localhost:
docker ps --format '{{.Names}}: {{.Ports}}' | sort

# No default credentials:
grep -rn "PASSWORD=admin\|PASSWORD=postgres" */docker-compose.yml

# UFW active:
ufw status verbose

# Docker iptables disabled:
cat /etc/docker/daemon.json
```

## Automated Script

```bash
# Full hardening:
sudo bash install/agent/harden-vps.sh

# With Tailscale SSH:
sudo bash install/agent/harden-vps.sh --tailscale-ssh

# Dry run first:
sudo bash install/agent/harden-vps.sh --dry-run
```

## Credential Management

- Generate random passwords: `openssl rand -base64 24 | tr -d '/+=' | head -c 24`
- Store at `~/.postgres_password`, `~/.grafana_password` (chmod 600)
- Never commit credentials to git
- Never use default credentials in any environment
- Rotate after any suspected exposure

## Pre-Deploy Checklist

Before **every** `docker compose up`:

- [ ] All ports in docker-compose.yml bound to `127.0.0.1`
- [ ] No default passwords (postgres, admin, root, password)
- [ ] `/etc/docker/daemon.json` has `{"iptables": false}`
- [ ] UFW active with deny-all + Tailscale exceptions
- [ ] `ss -tlnp | grep 0.0.0.0` shows only SSH (or nothing if Tailscale SSH)
- [ ] Tailscale is UP and reachable from another device
