# Rock5BPlus Fan Control

This is a bash script designed to modify the cooling levels in the device tree blob (DTB) of your Rock5BPlus board. With this script, you can easily control the PWM fan speed by either forcing the fan to run at full speed or restoring the default cooling levels.

> **Warning:** Modifying the device tree can potentially cause system issues. It is strongly recommended to create a backup and review the changes before proceeding. If you run this on the wrong board or image, it may brick the image.

## Features

- **Automatic Backup:** Creates a backup of the original DTB file before making any changes.
- **Interactive Mode:** Offers a simple menu to choose between:
  - Forcing full fan speed (all cooling levels set to `0xff`).
  - Restoring default cooling levels (`<0x00 0x40 0x80 0xc0 0xff>`).

## Prerequisites

- **Operating System:** Debian/Ubuntu or another Linux distribution with `apt` package manager.
- **Root Privileges:** The script must be run with root permissions.
- **Dependencies:** The script will install the `device-tree-compiler` if it's not already installed.

## Installation & Usage

```bash
sudo curl -sL https://raw.githubusercontent.com/IRLPlus/Rock5BFanControl/refs/heads/main/fan.sh | bash
