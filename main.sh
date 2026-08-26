#!/bin/bash
set -euo pipefail

# ==============================================================================
# Master CLI - Linux Systems Administration Suite
# ==============================================================================

# Ensure all scripts have execution permissions automatically.
# Covers .sh, .bash, and nested helper scripts under build-systems/.
chmod +x scripts/*.sh scripts/*.bash build-systems/*.sh 2>/dev/null || true

show_menu() {
    echo "===================================================="
    echo "    Linux Systems Administration & Security Suite   "
    echo "===================================================="
    echo "1. Setup Environment Dependencies (Requires Root access)"
    echo "2. Add/Configure Remote SSH Node"
    echo "3. System Automation & User Management"
    echo "4. File Encryption Vault & Build Systems"
    echo "5. Run Multi-Process System Monitor"
    echo "6. Exit"
    echo "===================================================="
}

while true; do
    echo ""
    show_menu
    read -r -p "Select an option [1-6]: " choice

    case $choice in
        1)
            # Run Dependency Setup
            sudo ./scripts/setup_env.sh
            ;;
        2)
            # Run SSH Node Setup
            ./scripts/add_ssh_node.sh
            ;;
        3)
            # Run User Management and Workspace Setup
            echo "--- User Creation ---"
            read -r -p  "Enter new username: " uname
            read -r -sp "Enter password: " pass
            echo ""
            read -r -p  "Enter primary group name: " gname
            
            # Call script 1
            sudo ./scripts/userdef.bash "$uname" "$pass" "$gname"

            # Call script 2 automatically for the created user
            echo ""
            echo "[INFO] Proceeding to Workspace Deployment..."
            sudo ./scripts/workspace_setup.bash "$uname"
            ;;
        4)
            # Run Vault Manager
            # We use subshell ( cd ... && ./... ) to ensure paths inside Vault script work correctly
            (cd build-systems && ./vault_manager.sh)
            ;;
        5)
            # Auto-compile the Task Manager first
            echo "[INFO] Ensuring Task Manager is compiled..."
            make -C sys-monitor all
            
            echo ""
            read -r -p "Run Task Manager locally or on remote alias? (local/<alias>): " target
            
            if [ "$target" == "local" ]; then
                ./sys-monitor/out/task_manager
            else
                # Push the compiled executable to the remote server's /tmp dir, then run it securely
                echo "[INFO] Deploying Task Manager to remote node '$target'..."
                scp ./sys-monitor/out/task_manager "$target":/tmp/task_manager
                ssh "$target" "chmod +x /tmp/task_manager && /tmp/task_manager"
            fi
            ;;
        6)
            echo "Exiting Suite. Goodbye!"
            exit 0
            ;;
        *)
            echo "[ERROR] Invalid option. Please choose a number between 1 and 6."
            ;;
    esac
done
