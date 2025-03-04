# 🛠️ Ubuntu Script Errors and Fixes

## 1️⃣ grub2-editenv: command not found ❌
**Issue:** `grub2-editenv` does not exist on Ubuntu. The equivalent command is `grub-editenv`.

**Fix:** Replace:
```bash
# Incorrect:
grub2-editenv - set "$(grub2-editenv - list | grep kernelopts) transparent_hugepage=never"
```
with:
```bash
# Correct:
grub-editenv /boot/grub/grubenv set "$(grub-editenv list | grep kernelopts) transparent_hugepage=never"
```

---
## 2️⃣ setfacl: command not found ❌
**Issue:** The `setfacl` command is missing because the `acl` package is not installed.

**Fix:** Add `acl` to the install command:
```bash
apt-get install -y acl
```

---
## 3️⃣ mkdir: cannot create directory ‘/opt/splunk’ ❌
**Issue:** The script tries to create `/opt/splunk`, but it already exists.

**Fix:** Change:
```bash
# Incorrect:
mkdir /opt/splunk
```
to:
```bash
# Correct:
mkdir -p /opt/splunk
```

---
## 4️⃣ chown: warning: '.' should be ':' ⚠️
**Issue:** In modern Ubuntu, `chown splunk. /opt/splunk` should use `:` instead of `.`.

**Fix:** Replace:
```bash
# Incorrect:
chown splunk. /opt/splunk
```
with:
```bash
# Correct:
chown splunk:splunk /opt/splunk
```

---
## 5️⃣ systemctl enable chronyd: Refusing to operate on alias name ❌
**Issue:** The service is named `chrony` on Ubuntu, not `chronyd`.

**Fix:** Replace:
```bash
# Incorrect:
systemctl enable chronyd
systemctl start chronyd
```
with:
```bash
# Correct:
systemctl enable chrony
systemctl start chrony
```

---
## 6️⃣ tar (child): /tmp/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz: Cannot open ❌
**Issue:** The script downloads the file to the current directory but tries to extract it from `/tmp/`.

**Fix:** Change:
```bash
# Incorrect:
sudo wget -O splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.3.2/linux/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz"
sudo tar -xzvf /tmp/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz -C /opt
```
to:
```bash
# Correct:
sudo wget -O /tmp/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/9.3.2/linux/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz"
sudo tar -xzvf /tmp/splunk-9.3.2-d8bb32809498-Linux-x86_64.tgz -C /opt
```

---
## 7️⃣ mv: cannot move '/tmp/user-seed.conf' ❌
**Issue:** The Splunk installation failed, so `/opt/splunk/etc/system/local/` does not exist.

**Fix:** Ensure Splunk is installed before moving files:
```bash
if [ -d "$SPLUNK_HOME/etc/system/local" ]; then
    mv /tmp/user-seed.conf $SPLUNK_HOME/etc/system/local/user-seed.conf
else
    echo "Splunk installation failed. Check logs."
    exit 1
fi
```

---
## 8️⃣ /opt/splunk/bin/splunk: No such file or directory ❌
**Issue:** The Splunk binary does not exist, possibly due to a failed extraction.

**Fix:** Add a check to ensure extraction was successful:
```bash
if [ ! -f "$SPLUNK_HOME/bin/splunk" ]; then
    echo "Splunk installation failed. Please check the extraction process."
    exit 1
fi
```

---
## 9️⃣ cowsay: command not found 🐮
**Issue:** The `cowsay` package might be missing.

**Fix:** Ensure `cowsay` is installed:
```bash
apt-get install -y cowsay
```

---
## ✅ Final Summary of Fixes 📝
✔️ Replace `grub2-editenv` with `grub-editenv`.
✔️ Install `acl` for `setfacl` commands.
✔️ Use `mkdir -p` to avoid errors if `/opt/splunk` already exists.
✔️ Use `:` instead of `.` in `chown`.
✔️ Change `chronyd` to `chrony` in `systemctl` commands.
✔️ Fix the `wget` download path to `/tmp/`.
✔️ Ensure `/opt/splunk/etc/system/local/` exists before moving `user-seed.conf`.
✔️ Verify Splunk installation before executing any commands.
✔️ Ensure `cowsay` is installed.

🚀 Now your script should run smoothly! 🎉

