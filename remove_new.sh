#!/bin/bash

echo "Stopping Splunk service..."
sudo -u splunk /opt/splunk/bin/splunk stop

echo "Disabling Splunk boot-start..."
sudo /opt/splunk/bin/splunk disable boot-start

echo "Removing Splunk installation directory..."
sudo rm -rf /opt/splunk

echo "Removing Splunk logs and temp files..."
sudo rm -rf /var/log/splunk /var/lib/splunk /var/run/splunk /var/tmp/splunk

echo "Removing Splunk user (optional)..."
sudo userdel -r splunk 2>/dev/null || echo "Splunk user does not exist."

echo "Removing Splunk sudo privileges..."
sudo rm -f /etc/sudoers.d/splunk

echo "Cleaning Splunk environment variables..."
sudo rm -f /etc/profile.d/splunk.sh

echo "Removing downloaded Splunk package..."
sudo rm -f /tmp/splunk-*.tgz

echo "Checking for remaining Splunk files..."
sudo find / -name "*splunk*" -exec rm -rf {} \; 2>/dev/null

echo "Splunk has been completely removed from the system."
