#!/bin/bash

# This script is for Ubuntu

# Update OS and install required packages
apt-get update -y
apt-get install -y \
    bc \
    net-tools \
    ncat \
    socat \
    nethogs \
    htop \
    vim \
    sysstat \
    nano \
    git \
    cowsay \
    chrony \
    rsync

# Setup crontab to delete old logs every hour
crontab -l > mycron
echo "0 */1 * * * /usr/bin/find /opt/syslog/ -type d -ctime +2 -exec rm -rf {} \;" >> mycron
crontab mycron
rm mycron

# Configure bash history to include timestamps
echo "# Add date/time information to bash history
export HISTTIMEFORMAT=\"%F %T \"" | sudo tee -a /etc/profile.d/sdaedu.sh && source /etc/profile.d/sdaedu.sh

# Configure user session timeout
cat >> /etc/bashrc << 'EOF'
# Added TMOUT as read-only for CIS compliance.
TMOUT=300
readonly TMOUT
export TMOUT
EOF

# Change default shell to bash in useradd command
sed -i '8d' /etc/default/useradd
sed -i '8iSHELL=/bin/bash' /etc/default/useradd \

# Create users and configure permissions
useradd -m splunk
useradd -m atlgsdachedu
usermod -a -G splunk atlgsdachedu
chage -M -1 atlgsdachedu
echo "atlgsdachedu ALL=(ALL) NOPASSWD:ALL" | tee --append /etc/sudoers.d/atlgsdachedu
echo "splunk ALL=(ALL) NOPASSWD:ALL" | sudo tee --append /etc/sudoers.d/splunk

# Revert default shell back to sh
sed -i '8d' /etc/default/useradd
sed -i '8iSHELL=/bin/sh' /etc/default/useradd \

# Set password requirements
echo "minlen = 8" | tee --append /etc/security/pwquality.conf

# Setup system resource limits
echo "Updating /etc/systemd/system.conf to increase ulimit values..."
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.bak
sudo sed -i.bak \
    -e 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=64000/' \
    -e 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=16000/' \
    -e 's/^#DefaultTasksMax=.*/DefaultTasksMax=80%/' \
    -e '/^DefaultLimitNOFILE=/!s/^DefaultLimitNOFILE=.*/DefaultLimitNOFILE=64000/' \
    -e '/^DefaultLimitNPROC=/!s/^DefaultLimitNPROC=.*/DefaultLimitNPROC=16000/' \
    -e '/^DefaultTasksMax=/!s/^DefaultTasksMax=.*/DefaultTasksMax=80%/' \
    /etc/systemd/system.conf

# Disable Transparent Huge Pages (THP)
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) transparent_hugepage=never"

# Setup Splunk user directory
mkdir /opt/splunk
chown -R splunk:splunk /opt/splunk

# File Permissions
chown splunk. /opt/splunk
setfacl -Rdm u:splunk:rX /var/log/
setfacl -Rm "u:splunk:r-X" /var/log/

# Message of the Day (MOTD) setup
mkdir /etc/motd.d
cat > /etc/motd.d/sdaedu << 'EOF'
ritaedu Splunk Build
EOF

# Enable and start Chrony time synchronization
systemctl enable chronyd
systemctl start chronyd

# Install Splunk
# echo 'export SPLUNK_HOME="/opt/splunk"' >> ~/.bashrc
# source ~/.bashrc
SPLUNK_HOME="/opt/splunk"
touch /tmp/user-seed.conf
cat > /tmp/user-seed.conf << 'EOF'
[user_info]
USERNAME = admin
PASSWORD = splunk123
EOF

# Download and install Splunk TAR version
sudo wget -O splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz "https://download.splunk.com/products/splunk/releases/9.4.0/linux/splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz"
sudo tar -xzvf /tmp/splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz -C /opt
sleep 2
echo 'oh yeah we are almost there...HAPPY SPLUNKING WITH ATLGSDACH SPLUNK ENG.'

# Move configuration files
mv /tmp/user-seed.conf $SPLUNK_HOME/etc/system/local/user-seed.conf
touch $SPLUNK_HOME/etc/.ui_login
sudo chown -Rf splunk:splunk $SPLUNK_HOME

# Enable Splunk boot-start and start Splunk
$SPLUNK_HOME/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt
sleep 2
echo -e "[settings]\nstartwebserver = True\nenableSplunkWebSSL = True\nsslVersions = tls1.2\n" >> $SPLUNK_HOME/etc/system/local/web.conf
sudo chown -Rf splunk:splunk $SPLUNK_HOME
$SPLUNK_HOME/bin/splunk start

# Display success message
cowsay -f tux "WoHoo..Welcome to ATLGSDACH EDU..You installed SPLUNK successfully"
echo "done"

# Optional cleanup and removal commands (commented out)
##kill `ps -ef | grep splunkd | egrep -v grep | awk '{print $2}'`
##removing splunk RPM
##rpm -qa | grep -i splunk
##rpm -e <.rpm>
##sudo pkill -f splunk
