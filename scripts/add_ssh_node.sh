#!/bin/bash
set -euo pipefail

echo "===================================================="
echo "          Automated SSH Node Provisioning           "
echo "===================================================="

SSH_DIR="$HOME/.ssh"
KEY_PATH="$SSH_DIR/id_ed25519"

# 1. Check or generate SSH key
if [ ! -f "$KEY_PATH" ]; then
    echo "[INFO] Generating new SSH key pair (Ed25519 with empty passphrase)..."
    mkdir -p "$SSH_DIR" && chmod 700 "$SSH_DIR"
    ssh-keygen -t ed25519 -N "" -f "$KEY_PATH" -C "$(whoami)@$(hostname)-$(date +%Y%m%d)" > /dev/null
    echo "[SUCCESS] SSH key created at $KEY_PATH"
else
    echo "[OK] Existing SSH key detected."
fi

# 2. Get Remote Node Details from User
read -r -p "Enter Remote Server IP or Hostname: " REMOTE_HOST
read -r -p "Enter Remote Username: " REMOTE_USER
read -r -p "Enter Alias Name for this Node (e.g., node1): " NODE_ALIAS

if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ] || [ -z "$NODE_ALIAS" ]; then
    echo "[ERROR] All inputs are required!" >&2
    exit 1
fi

# 3. Push Public Key to Remote Server
echo "[INFO] Transferring SSH Public Key to $REMOTE_USER@$REMOTE_HOST..."
echo "[NOTE] You will be asked for the remote user's password ONCE."

if ! ssh-copy-id -i "${KEY_PATH}.pub" "$REMOTE_USER@$REMOTE_HOST"; then
    echo "[ERROR] Failed to copy SSH key to target server." >&2
    exit 1
fi

# 4. Update ~/.ssh/config for passwordless alias access
CONFIG_FILE="$SSH_DIR/config"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

if grep -qE "^Host[[:space:]]+$NODE_ALIAS([[:space:]]|$)" "$CONFIG_FILE"; then
    echo "[WARNING] Alias '$NODE_ALIAS' already exists in $CONFIG_FILE. Skipping config write."
else
    {
        printf "\nHost %s\n"  "$NODE_ALIAS"
        printf "  HostName %s\n" "$REMOTE_HOST"
        printf "  User %s\n"    "$REMOTE_USER"
        printf "  IdentityFile %s\n" "$KEY_PATH"
    } >> "$CONFIG_FILE"
    echo "[SUCCESS] Node '$NODE_ALIAS' configured in $CONFIG_FILE."
fi

# 5. Test Passwordless SSH Connection.
# Use a remote-side `hostname` so the printed name is the *remote* host's,
# and detect failure rather than just printing a generic message.
echo "[INFO] Testing connection to '$NODE_ALIAS'..."
REMOTE_NAME=$(ssh -o BatchMode=yes -o ConnectTimeout=5 "$NODE_ALIAS" 'hostname' 2>/dev/null) || {
    echo "[WARNING] Could not verify passwordless SSH connection." >&2
    exit 0
}
echo "[SUCCESS] Connected to ${REMOTE_NAME:-unknown} successfully via Passwordless SSH!"
