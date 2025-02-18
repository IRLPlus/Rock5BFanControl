#!/bin/bash
# rock5bplus-fan-control.sh
#
# Rock5BPlus Fan Control
#
# This script modifies the cooling-levels in the DTB file for the Rock5BPlus board to control the PWM fan speed.
# It creates a backup of the DTB file, decompiles the DTB, and lets you choose:
#   1. Force full fan speed (fan always on full speed)
#   2. Restore default cooling levels (<0x00 0x40 0x80 0xc0 0xff>)
#

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try running with sudo."
    exit 1
fi

# Define file paths
DTB_FILE="/boot/dtb/rockchip/rk3588-rock-5b-plus.dtb"
BACKUP_FILE="/boot/dtb/rockchip/rk3588-rock-5b-plus.dtb.bak"
DTS_FILE="/tmp/rk3588-rock-5b-plus.dts"

# Ensure device-tree-compiler is installed
if ! command -v dtc &> /dev/null; then
    echo "device-tree-compiler (dtc) not found. Installing..."
    apt update && apt install -y device-tree-compiler
    if [ $? -ne 0 ]; then
        echo "Installation of device-tree-compiler failed. Exiting."
        exit 1
    fi
fi

echo "Creating backup of DTB file..."
cp "$DTB_FILE" "$BACKUP_FILE"
if [ $? -ne 0 ]; then
    echo "Failed to create backup of $DTB_FILE. Exiting."
    exit 1
fi

echo "Decompiling DTB to DTS..."
if ! dtc -I dtb -O dts -o "$DTS_FILE" "$DTB_FILE" > /dev/null 2>&1; then
    echo "Failed to decompile $DTB_FILE. Exiting."
    exit 1
fi

# Ask the user which fan mode to set (reading explicitly from /dev/tty)
echo "Choose the fan mode you want to apply:"
echo "1) Force full fan speed (fan always on full speed)"
echo "2) Restore default cooling levels (<0x00 0x40 0x80 0xc0 0xff>)"
read -p "Enter your choice (1 or 2): " choice </dev/tty

case "$choice" in
    1)
        echo "Setting cooling-levels to force full fan speed..."
        NEW_VALUES="0xff 0xff 0xff 0xff 0xff"
        ;;
    2)
        echo "Restoring default cooling levels..."
        NEW_VALUES="0x00 0x40 0x80 0xc0 0xff"
        ;;
    *)
        echo "Invalid choice. Exiting without making changes."
        rm -f "$DTS_FILE"
        exit 1
        ;;
esac

# Modify the cooling-levels property in the DTS file
sed -i "s/\(cooling-levels\s*=\s*<\)[^>]*\(>;\)/\1$NEW_VALUES\2/" "$DTS_FILE"
if [ $? -ne 0 ]; then
    echo "Failed to modify the cooling-levels property. Exiting."
    rm -f "$DTS_FILE"
    exit 1
fi

echo "Recompiling DTS back to DTB..."
if ! dtc -I dts -O dtb -o "$DTB_FILE" "$DTS_FILE" > /dev/null 2>&1; then
    echo "Failed to compile DTS back into DTB. Exiting."
    rm -f "$DTS_FILE"
    exit 1
fi

# Clean up temporary DTS file
rm -f "$DTS_FILE"

echo "DTB modification complete."

# Prompt the user to reboot (again reading explicitly from /dev/tty)
read -p "Would you like to reboot now for changes to take effect? (y/n): " answer </dev/tty
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Rebooting..."
    reboot
else
    echo "Please remember to reboot later for the changes to take effect."
fi
