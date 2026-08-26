#!/bin/bash
set -euo pipefail

# --- argument validation ----------------------------------------------------
if [ $# -ne 3 ]; then
    echo "[ERROR] Usage: $0 <username> <password> <groupname>" >&2
    exit 1
fi

username=$1
pass=$2
groupname=$3

# POSIX-safe username/groupname regex.
name_re='^[a-z_][a-z0-9_-]{0,31}$'
if ! [[ "$username" =~ $name_re ]]; then
    echo "[ERROR] Invalid username '$username' (must match $name_re)." >&2
    exit 1
fi
if ! [[ "$groupname" =~ $name_re ]]; then
    echo "[ERROR] Invalid groupname '$groupname' (must match $name_re)." >&2
    exit 1
fi
if [ -z "$pass" ]; then
    echo "[ERROR] Password must not be empty." >&2
    exit 1
fi

# Check sudo permissions using EUID
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] This script must be run as root (sudo)" >&2
    exit 1
fi

echo "[INFO] Input details:"
echo "       Username:  $username"
echo "       Groupname: $groupname"

# Idempotency: bail if the user already exists so we don't re-set their
# password and UID on a re-run.
if id "$username" >/dev/null 2>&1; then
    echo "[ERROR] User '$username' already exists." >&2
    exit 1
fi

# Create user with home directory and default bash shell
useradd -m -s /bin/bash -N "$username"

# Set user password silently
echo "$username:$pass" | chpasswd
echo "[SUCCESS] User '$username' created."

# Create group with specific GID (only if it doesn't already exist).
if getent group "$groupname" >/dev/null 2>&1; then
    echo "[OK] Group '$groupname' already exists; reusing it."
elif groupadd -g 200 "$groupname" 2>/dev/null; then
    echo "[SUCCESS] Group '$groupname' (GID: 200) created."
else
    # GID 200 was probably taken — fall back to a system-assigned GID.
    echo "[WARN] GID 200 unavailable for '$groupname'; falling back to system-assigned GID."
    groupadd "$groupname"
fi

# Assign user to group, update UID and primary group.
usermod -aG "$groupname" "$username"
usermod -u 1600 "$username"
usermod -g "$groupname" "$username"

echo "------------------- User Details Verification -------------------"
id "$username"
