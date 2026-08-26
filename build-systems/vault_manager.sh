#!/bin/bash
set -euo pipefail

# مسارات التطبيق والـ Makefile
APP_DIR="./Application"
OUT_DIR="$APP_DIR/out"
EXECUTABLE="$OUT_DIR/vault_cli"

echo "===================================================="
echo "      Security Vault & Build Automation Tool        "
echo "===================================================="

build_project() {
    echo "[INFO] Starting Automated Build Process..."
    make -C "$APP_DIR" clean
    make -C "$APP_DIR" all

    if [ -f "$EXECUTABLE" ]; then
        echo "[SUCCESS] Build completed. Executable ready at $EXECUTABLE"
    else
        echo "[ERROR] Build failed." >&2
        exit 1
    fi
}

show_menu() {
    while true; do
        echo ""
        echo "-------------------------------------------------"
        echo "1. Build/Rebuild Encryption Suite"
        echo "2. Encrypt a File (Secure Vault)"
        echo "3. Decrypt a File"
        echo "4. Exit"
        echo "-------------------------------------------------"
        read -r -p "Select an option [1-4]: " choice

        case "$choice" in
            1)
                build_project
                ;;
            2)
                if [ ! -f "$EXECUTABLE" ]; then
                    echo "[ERROR] Executable not found. Please build the project first (Option 1)." >&2
                    continue
                fi
                read -r -p "Enter file path to encrypt: " filepath
                read -r -p "Select Algorithm (caesar/xor): " algo
                read -r -p "Enter Secret Key: " key

                # Pass LD_LIBRARY_PATH inline to the child process only —
                # don't `export` it, or it leaks into the user's shell
                # for the rest of the session.
                LD_LIBRARY_PATH="$OUT_DIR/libs:${LD_LIBRARY_PATH:-}" \
                    "$EXECUTABLE" encrypt "$algo" "$filepath" "$key"
                ;;
            3)
                if [ ! -f "$EXECUTABLE" ]; then
                    echo "[ERROR] Executable not found." >&2
                    continue
                fi
                read -r -p "Enter file path to decrypt (.enc): " filepath
                read -r -p "Select Algorithm (caesar/xor): " algo
                read -r -p "Enter Secret Key: " key

                LD_LIBRARY_PATH="$OUT_DIR/libs:${LD_LIBRARY_PATH:-}" \
                    "$EXECUTABLE" decrypt "$algo" "$filepath" "$key"
                ;;
            4)
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac
    done
}

show_menu
