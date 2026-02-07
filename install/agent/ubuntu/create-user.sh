#!/bin/bash
#
# Create agent user for Ubuntu
# Run as root before hardening
#
# Usage: ./create-user.sh [username]
#

set -e

USERNAME="${1:-clank}"

echo "🤖 Creating user: $USERNAME"

# Create user with bash (zsh installed later)
useradd -m -s /bin/bash "$USERNAME"
usermod -aG sudo "$USERNAME"

# Passwordless sudo
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USERNAME"
chmod 440 "/etc/sudoers.d/$USERNAME"

# Copy SSH keys from root
mkdir -p "/home/$USERNAME/.ssh"
cp ~/.ssh/authorized_keys "/home/$USERNAME/.ssh/"
chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.ssh"
chmod 700 "/home/$USERNAME/.ssh"
chmod 600 "/home/$USERNAME/.ssh/authorized_keys"

echo "✓ User $USERNAME created with SSH access"
echo "✓ Test with: ssh $USERNAME@\$(hostname -I | awk '{print \$1}')"
