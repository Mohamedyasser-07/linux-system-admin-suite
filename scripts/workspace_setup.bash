#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "[ERROR] Usage: $0 <target_username>" >&2
    exit 1
fi

username=$1

# Resolve the user's home directory safely via getent — never `eval`
# user input; an attacker could inject arbitrary commands otherwise.
user_home=$(getent passwd "$username" | cut -d: -f6)
if [ -z "$user_home" ] || [ ! -d "$user_home" ]; then
    echo "[ERROR] Home directory for '$username' ($user_home) does not exist." >&2
    exit 1
fi

dir="my_project"

# Clean up existing workspace directory in the *current* working dir.
if [ -d "$dir" ]; then
   rm -rf "$dir"
fi

# Create directory and target files
mkdir -p "$dir" && touch "$dir/main.c" "$dir/main.h" "$dir/hello.c" "$dir/hello.h"

# Populate files
for file in "$dir"/*.c "$dir"/*.h; do
    printf 'this file is named: %s\n' "$(basename "$file")" > "$file"
done

# Create tar archive
tar -cf "$dir.tar" "$dir"

# Deploy to target user home directory. Use -C when untarring instead
# of -C cp, which keeps the cp step trivial.
cp "$dir.tar" "$user_home/$dir.tar"
tar -xf "$user_home/$dir.tar" -C "$user_home/"

# Restore ownership of the deployed tree and the tarball.
# Use the user's primary group rather than assuming it equals the
# username (which is not always true with -N / explicit -g).
user_group=$(id -gn "$username")
chown -R "$username:$user_group" "$user_home/$dir" "$user_home/$dir.tar"

# Best-effort cleanup of the staging dir we made locally.
rm -rf "$dir" "$dir.tar"

echo "[SUCCESS] Deployment completed for '$username' in $user_home."
