Readme · MD
# Linux Systems Administration & Security Suite
 
Interactive Bash-based Linux sysadmin toolkit for automating environment setup, remote SSH configuration, user/automation management, file encryption, and multi-process system monitoring.
 
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue)
 
## Overview
 
This project brings together several everyday sysadmin workflows into a single, menu-driven suite so they can be run consistently without memorizing individual commands or scripts. It was built as a hands-on exercise in Bash scripting, Linux system internals, and basic security tooling.
 
## Features
 
- **Environment Setup** — installs and configures required system dependencies (requires root access)
- **Remote SSH Node Management** — adds and configures SSH connections to remote machines
- **System Automation & User Management** — scripted user account and automation task handling
- **File Encryption Vault** — encrypts/decrypts files and manages related build systems
- **Multi-Process System Monitor** — runs a live monitor across multiple system processes
## Demo
 
```
=====================================================
    Linux Systems Administration & Security Suite
=====================================================
1. Setup Environment Dependencies (Requires Root access)
2. Add/Configure Remote SSH Node
3. System Automation & User Management
4. File Encryption Vault & Build Systems
5. Run Multi-Process System Monitor
6. Exit
=====================================================
Select an option [1-6]:
```
 
## Requirements
 
- Linux (tested on: *add your distro/version here*)
- Bash 4.0+
- `sudo`/root access for dependency setup and certain administrative tasks
- *List any other dependencies here, e.g. openssh-client, openssl, cron, etc.*
## Installation
 
```bash
git clone https://github.com/Mohamedyasser-07/linux-system-admin-suite.git
cd linux-system-admin-suite
chmod +x main.sh
```
 
## Usage
 
Run the main script and select an option from the menu:
 
```bash
./main.sh
```
 
| Option | Description |
|--------|-------------|
| 1 | Setup environment dependencies (requires root) |
| 2 | Add/configure a remote SSH node |
| 3 | System automation & user management |
| 4 | File encryption vault & build systems |
| 5 | Run the multi-process system monitor |
| 6 | Exit |
 
## Project Structure
 
```
linux-system-admin-suite/
├── main.sh              # Entry point / interactive menu
├── scripts/              # Individual feature scripts
│   ├── setup_env.sh
│   ├── ssh_config.sh
│   ├── user_management.sh
│   ├── file_vault.sh
│   └── system_monitor.sh
└── README.md
```
 
## Skills Demonstrated
 
- Bash scripting and shell automation
- Linux system administration fundamentals
- SSH configuration and remote access management
- User/permission management
- File encryption and secure storage practices
- Process monitoring and system resource management
## Roadmap / Possible Improvements
 
- [ ] Add logging for all executed actions
- [ ] Add config file support instead of hardcoded values
- [ ] Add unit/integration tests
- [ ] Support additional Linux distributions
## License
 
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
 
## Author
 
**Mohamed**
