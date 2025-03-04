#!/bin/bash

# Define variables
SPLUNK_HOME="/opt/splunk"
SPLUNK_USER="splunk"
ATL_USER="atlgsdachedu"

# Function to safely remove users and their home directories
remove_user() {
    local user=$1
    if id "$user" &>/dev/null; then
        echo "Removing user: $user"
        sudo userdel -r "$user"
    else
        echo "User $user does not exist. Skipping."
    fi
}

# Stop and disable Splunk service
if [ -f "$SPLUNK_HOME/bin/splunk" ]; then
    echo "Stopping Splunk..."
    sudo -u splunk $SPLUNK_HOME/bin/splunk stop
fi

# Change ownership to root and remove Splunk installation
if [ -d "$SPLUNK_HOME" ]; then
    echo "Changing ownership and removing Splunk directory..."
    sudo chown -R root:root "$SPLUNK_HOME"
    sudo chmod -R u+w "$SPLUNK_HOME"
    sudo rm -rf "$SPLUNK_HOME"
fi

# Remove downloaded Splunk package
sudo rm -f /tmp/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz

# Remove created users
remove_user "$SPLUNK_USER"
remove_user "$ATL_USER"

# Unlock /etc/passwd if necessary
sudo rm -f /etc/passwd.lock
sudo rm -f /etc/shadow.lock

# Restore system configuration files (if backups exist)
if [ -f /etc/systemd/system.conf.bak ]; then
    echo "Restoring system configuration files..."
    sudo mv /etc/systemd/system.conf.bak /etc/systemd/system.conf
fi

# Remove specific cron job entry (without clearing the entire crontab)
crontab -l | grep -v '/usr/bin/find /opt/syslog/' | crontab -

# Remove only custom sudoers configurations
sudo rm -f /etc/sudoers.d/splunk
sudo rm -f /etc/sudoers.d/atlgsdachedu

# Restore default useradd shell configuration if modified
if grep -q "SHELL=/bin/bash" /etc/default/useradd; then
    sudo sed -i 's|SHELL=/bin/bash|SHELL=/bin/sh|' /etc/default/useradd
fi

# Remove custom Message of the Day (MOTD), but keep system defaults
if [ -d /etc/motd.d ]; then
    sudo rm -rf /etc/motd.d
fi

# Disable Chrony service if it was installed manually for Splunk
if systemctl list-units --full -all | grep -q "chrony.service"; then
    sudo systemctl disable --now chrony
fi

# Reset Transparent Huge Pages (THP) settings to default
if [ -f /sys/kernel/mm/transparent_hugepage/enabled ]; then
    echo 'always' | sudo tee /sys/kernel/mm/transparent_hugepage/enabled
    echo 'always' | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
fi

# Final message
echo "All custom Splunk-related components removed successfully! System cleaned up."
