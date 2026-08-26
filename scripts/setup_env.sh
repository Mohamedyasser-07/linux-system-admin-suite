#!/bin/bash
# Fail fast on errors and on undefined variables — apt-get failures
# shouldn't be silently swallowed.
set -euo pipefail

# Ensure script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Please run as root (sudo ./setup_env.sh)" >&2
    exit 1
fi

echo "===================================================="
echo "       System Dependencies & SSH Setup Tool        "
echo "===================================================="

# Update package lists
echo "[INFO] Updating package list..."
if ! apt-get update -y; then
    echo "[ERROR] apt-get update failed." >&2
    exit 1
fi

# Required packages array
PACKAGES=("gcc" "make" "cmake" "sysstat" "openssh-server" "openssh-client")

for pkg in "${PACKAGES[@]}"; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
        echo "[OK] $pkg is already installed."
    else
        echo "[INSTALLING] $pkg..."
        if apt-get install -y "$pkg"; then
            echo "[SUCCESS] Installed $pkg."
        else
            echo "[ERROR] Failed to install $pkg." >&2
            # Don't abort the whole loop — keep trying the rest.
        fi
    fi
done

# Enable and start SSH service
echo "[INFO] Configuring SSH Service..."
systemctl enable ssh > /dev/null 2>&1 || echo "[WARN] systemctl enable ssh failed." >&2
systemctl start ssh  || echo "[WARN] systemctl start ssh failed."  >&2

if systemctl is-active --quiet ssh; then
    echo "[SUCCESS] SSH service is active and running."
else
    echo "[ERROR] SSH service failed to start." >&2
fi

echo "===================================================="
echo "[SUCCESS] Environment Setup Complete!"
echo "===================================================="
