#!/bin/bash
set -e
# Installs brightctl application for the current user
echo "Installing brightctl..."

# Check for ddcutil
if ! command -v ddcutil &>/dev/null; then
    echo "Error: ddcutil is required. Please install it with 'sudo apt install ddcutil'."
    exit 1
fi

# Install scripts
mkdir -p "$HOME/.local/bin"
install -m 755 scripts/brightctl.sh "$HOME/.local/bin/brightctl.sh"
install -m 755 scripts/run_brightctl.sh "$HOME/.local/bin/run_brightctl.sh"

# Install systemd units
mkdir -p "$HOME/.config/systemd/user"
for unit in systemd/*.service systemd/*.timer; do
    install -m 644 "$unit" "$HOME/.config/systemd/user/"
done

# Reload systemd and enable units
systemctl --user daemon-reload
systemctl --user enable brightctl-day.timer brightctl-night.timer brightctl-session.service
systemctl --user start brightctl-day.timer brightctl-night.timer

echo "Installation complete. brightctl is set up for user $USER."
