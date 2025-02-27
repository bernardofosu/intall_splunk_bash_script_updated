# 🚀 Install Splunk Using a Bash Script

## 📌 Key Notes:
✅ This script installs Splunk 9.4.0 for Linux.

✅ Designed for Ubuntu, but can be modified for other distros.

✅ If you're using Amazon Linux, replace apt with yum.

✅ For RedHat, replace apt with dnf.

## 🛠 Installation Instructions:
**1️⃣** Open the install_splunk.sh script file using any text editor.

**2️⃣** Copy all the script content.

**3️⃣** On your server, use a text editor (nano or vi) and paste the script.

**4️⃣** Save the file and exit the editor.

## 🔐 Grant Execution Permissions:
After creating the script, run the following command to make it executable:
```sh
sudo chmod +x install_splunk.sh
```

### 🚀 Run the installation script
```sh
sudo ./install_splunk.sh
```
##### 📌 Note:
_**./** means you are running the script from the current directory. If you are not in the current directory, use the full path to the script instead_

_🔑 Using sudo ensures proper permissions for installation!_

_👤 If you're not using the root user, you'll need sudo to perform administrative actions during installation_

## 📜 What’s Inside the Installation Script?

### 1️⃣ Shebang & Description
```bash
#!/bin/bash
```
This line tells the system that the script should be run using the Bash shell.

### 2️⃣ Updating OS & Installing Required Packages 🛠️
```bash
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
```
- apt-get update -y: Updates the package list to get the latest versions. 🔄
- apt-get install -y ...: Installs useful tools like:
bc: Calculator 📊
- net-tools: Network utilities 🌐
- ncat, socat: Networking tools 🚀
- htop: System monitoring 📈
- vim, nano: Text editors ✍️
- git: Version control 🔄
- cowsay: Fun ASCII messages 🐄
- chrony: Time synchronization ⏳
- rsync: File syncing tool 🔄

### 3️⃣ Setting Up Log Cleanup in Cron ⏰
```bash
crontab -l > mycron
echo "0 */1 * * * /usr/bin/find /opt/syslog/ -type d -ctime +2 -exec rm -rf {} \;" >> mycron
```
- crontab mycron
- rm mycron
- 
Creates a cron job that deletes logs older than 2 days, every hour. 📜🧹

### 4️⃣ Configure Bash History to Show Timestamps ⏳
```bash
echo "# Add date/time information to bash history
export HISTTIMEFORMAT=\"%F %T \"" | sudo tee -a /etc/profile.d/sdaedu.sh && source /etc/profile.d/sdaedu.sh
```
#### Adds timestamps 
🕒 to Bash history so commands are logged with date/time.
#### Explanation:
- HISTTIMEFORMAT=\"%F %T \":
- %F expands to YYYY-MM-DD format.
- %T expands to HH:MM:SS (24-hour time format).
[Read More on History and TimeStamp](history_timestamp.md)

### 5️⃣ User Session Timeout (Security) 🔒
```bash
cat >> /etc/bashrc << 'EOF'
# Added TMOUT as read-only for CIS compliance.
TMOUT=300
readonly TMOUT
export TMOUT
EOF
```
This configuration enforces an automatic logout after 5 minutes of inactivity, which helps improve system security by preventing unauthorized access to idle terminals. The setting is immutable, ensuring users cannot override it.
- Sets a session timeout of 300 seconds (5 minutes) ⏳
- Enforces security by automatically logging out inactive users.

### 6️⃣ Change Default Shell to Bash 🐚
```bash
sed -i '8d' /etc/default/useradd
sed -i '8iSHELL=/bin/bash' /etc/default/useradd \
```
Modifies the default shell to Bash (/bin/bash) for new users.
Bash is More Powerful: Bash (Bourne Again Shell) is more feature-rich than /bin/sh. It supports:
- Command history.
- Tab-completion.
- Scripting enhancements.

### 7️⃣ Create Users & Configure Permissions 👥
```bash
useradd -m splunk
useradd -m atlgsdachedu
usermod -a -G splunk atlgsdachedu
chage -M -1 atlgsdachedu
echo "splunk:splunk123" | sudo chpasswd
echo "atlgsdachedu:splunk123" | sudo chpasswd
echo "atlgsdachedu ALL=(ALL) NOPASSWD:ALL" | tee --append /etc/sudoers.d/atlgsdachedu
echo "splunk ALL=(ALL) NOPASSWD:ALL" | sudo tee --append /etc/sudoers.d/splunk
```
Creates users:
- splunk: For running Splunk.
- atlgsdachedu: Additional user.
- Create Password for users
-Gives atlgsdachedu sudo access 🔑

### 8️⃣ Restore Default Shell to /bin/sh
```bash
sed -i '8d' /etc/default/useradd
sed -i '8iSHELL=/bin/sh' /etc/default/useradd \
```
#### Reverts the default shell to /bin/sh.
splunk user will still have Bash (/bin/bash) as its default shell unless explicitly changed.
##### Why?
- Changing the default shell in /etc/default/useradd only affects new users created after the change.
- Since splunk was created before the default was changed back to /bin/sh, it will retain whatever shell was assigned during its creation (/bin/bash in this case).

### 9️⃣ Set Password Complexity Rules 🔐
```sh
Edit
echo "minlen = 8" | tee --append /etc/security/pwquality.conf
```
Enforces a minimum password length of 12 characters for security.

### 🔟 System Resource Limits Optimization 🚀
```bash
sed -i 's/#DefaultLimitNOFILE=/# atlgsdachedu modified value below\nDefaultLimitNOFILE=65000/' /etc/systemd/system.conf
sed -i 's/#DefaultLimitNPROC=/# atlgsdachedu modified value below\nDefaultLimitNPROC=16000/' /etc/systemd/system.conf
sed -i 's/#DefaultTasksMax=80%/# atlgsdachedu modified value below\nDefaultTasksMax=8192/' /etc/systemd/system.conf
```
Here are the updated sed commands without the comments:
```sh
sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=64000/' /etc/systemd/system.conf
sed -i 's/#DefaultLimitNPROC=/DefaultLimitNPROC=16000/' /etc/systemd/system.conf
sed -i 's/#DefaultTasksMax=80%/DefaultTasksMax=8192/' /etc/systemd/system.conf
```
Optimizes system performance by adjusting limits:
NOFILE=64000 (Max open files) 📂
NPROC=16000 (Max processes per user) 🔄
TasksMax=8192 (Max tasks per service)

Command to Check Changes:
```sh
grep -E 'DefaultLimitNOFILE|DefaultLimitNPROC|DefaultTasksMax' /etc/systemd/system.conf
```
The **-E** flag in grep stands for "extended regular expressions" (ERE). It allows the use of more complex pattern-matching syntax compared to basic regular expressions.

Explanation:
- grep -E: Enables extended regular expressions, allowing the use of | for "or" conditions without needing to escape it (i.e., \|).
- 'DefaultLimitNOFILE|DefaultLimitNPROC|DefaultTasksMax': This pattern searches for any line in the file that contains DefaultLimitNOFILE, DefaultLimitNPROC, or DefaultTasksMax.
- /etc/systemd/system.conf: Specifies the file to search.

Purpose:
- The command will print any lines from /etc/systemd/system.conf that contain one or more of the specified strings. This is useful for verifying the updated ulimit values in the configuration file.

### 1️⃣1️⃣ Disable Transparent Huge Pages (THP) 🚀
```bash
echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) transparent_hugepage=never"
```
Improves performance by disabling THP (reduces memory fragmentation).
### Why Use These Commands?
- Performance Improvements: Disabling THP can improve performance for some applications, especially databases like MongoDB, Splunk, and Redis, which are sensitive to the overhead THP can introduce.
- System-Wide Consistency: By setting the option in GRUB, the configuration persists across reboots, ensuring the system behavior remains consistent.

### 1️⃣2️⃣ Setup Splunk User Directory 📂
```bash
mkdir /opt/splunk
chown -R splunk:splunk /opt/splunk
```
Creates /opt/splunk for Splunk installation.

### 1️⃣3️⃣ File Permissions 🔐
```bash
chown splunk. /opt/splunk
setfacl -Rdm u:splunk:rX /var/log/
setfacl -Rm "u:splunk:r-X" /var/log/
```
**setfacl** is a Linux command used to manage Access Control Lists (ACLs), which provide fine-grained control over file and directory permissions beyond the traditional Unix file permission model. ACLs allow you to grant specific users or groups permissions on files and directories, without changing ownership or group settings.

Benefits of Using ACLs:
- Granular Control: You can set permissions for individual users or groups without changing the file owner or group.
- Inheritance: Default ACLs ensure consistent permissions for newly created files.
- Flexibility: ACLs complement traditional Unix permissions for more complex permission scenarios.

Sets permissions so the Splunk user can read logs.

### 1️⃣4️⃣ Customize Message of the Day (MOTD) 🖥️
```bash
mkdir /etc/motd.d
cat > /etc/motd.d/sdaedu << 'EOF'
ritaedu Splunk Build
EOF
```
Customizes login greeting with a message. 🎉
MOTD (Message of the Day):
- It’s a banner message displayed when users log in to the system via the command line.
- This command customizes the MOTD to display the message "ritaedu Splunk Build," which could be used to inform users about the Splunk setup or branding.

### 1️⃣5️⃣ Enable & Start Chrony Time Sync ⏰
```bash
systemctl enable chronyd
systemctl start chronyd
```
Why Use These Commands?
- Ensures the system clock stays accurate.
- Necessary for log files, Splunk data indexing, and other time-sensitive operations.
- Critical for distributed systems to maintain consistent timestamps.

### 1️⃣6️⃣ Download & Install Splunk 🟠
#### Creating user-seed.conf:
user-seed.conf is a file defined by Splunk, and it is used to create an initial administrator account during the first-time startup of Splunk

##### How Splunk Uses user-seed.conf
One-Time Use:
- The credentials from user-seed.conf are only applied during the first startup.
-  After that, the file is deleted by Splunk to prevent security risks.

No UI Prompt:
- This approach is often used in automated installations or deployments (e.g., scripted installations, Docker containers).
```bash
SPLUNK_HOME="/opt/splunk"
touch /tmp/user-seed.conf
cat > /tmp/user-seed.conf << 'EOF'
[user_info]
USERNAME = admin
PASSWORD = splunk123
EOF

sudo wget -O splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz "https://download.splunk.com/products/splunk/releases/9.4.0/linux/splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz"
sudo tar -xzvf /tmp/splunk-9.4.0-6b4ebe426ca6-linux-amd64.tgz -C /opt
sleep 2
echo 'oh yeah we are almost there...HAPPY SPLUNKING WITH ATLGSDACH SPLUNK ENG.'
```
- The touch /tmp/user-seed.conf ensures the file exists (although unnecessary if cat is used).
- The cat > /tmp/user-seed.conf << 'EOF' ... EOF defines the admin username and password for initial setup. This file is used by Splunk for first-time authentication setup.

#### /opt/splunk already exists, extracting the Splunk tarball with sudo tar -xzvf -C /opt will overwrite existing files with the same names but will not delete any files or directories that are not in the tarball.
Here's how it works:
- Files with the same name: They will be replaced with the files from the tarball.
- New files: Files in the tarball that don't already exist in /opt/splunk will be added.
- Existing files not in the tarball: Any files in /opt/splunk that are not part of the Splunk tarball will remain unchanged.

What this means:
- If you are upgrading or reinstalling Splunk, it may preserve configurations (e.g., server.conf, inputs.conf, etc.) as long as they are not overwritten by the tarball.
- Backup recommended: Before running the extraction, it's usually best to create a backup (e.g., cp -r /opt/splunk /opt/splunk_backup) to avoid unintentional loss of custom files or configurations.

Downloads & installs Splunk 9.4.0 from the official site.

### 1️⃣7️⃣ Configure & Start Splunk 🚀
```bash
mv /tmp/user-seed.conf $SPLUNK_HOME/etc/system/local/user-seed.conf
touch $SPLUNK_HOME/etc/.ui_login
sudo chown -Rf splunk:splunk $SPLUNK_HOME
$SPLUNK_HOME/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt
sleep 2
echo -e "[settings]\nstartwebserver = True\nenableSplunkWebSSL = True\nsslVersions = tls1.2\n" >> $SPLUNK_HOME/etc/system/local/web.conf
sudo chown -Rf splunk:splunk $SPLUNK_HOME
$SPLUNK_HOME/bin/splunk start
```
Moves config files and starts Splunk ✅
1️⃣8️⃣ Success Message 🎉
```bash
cowsay -f tux "WoHoo..Welcome to ATLGSDACH EDU..You installed SPLUNK successfully"
echo "done"
```
Displays a fun success message with cowsay 🐄

## 🚀 Simplifying Splunk Installation for the Architect Class
Since we are installing multiple Splunk instances for the architect class, I have designed a Bash script to streamline the process and speed up our work.  

If you encounter any issues while using it, please let me know. I'm happy to help! 😊  

#### 💬 **Share Your Views!**  
Join the discussion on the repository to share feedback and suggestions for improvement.  

#### 🔧 **Want to Contribute?**  
You can **fork** the repository, modify the script, and send a **pull request** to enhance it! 🚀  

Thank you for your support! 🙌  