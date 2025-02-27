```sh
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
```

```sh
# Backup the original file
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.bak

# Remove existing lines (both commented and uncommented)
sudo sed -i '/^#*DefaultLimitNOFILE=/d' /etc/systemd/system.conf
sudo sed -i '/^#*DefaultLimitNPROC=/d' /etc/systemd/system.conf
sudo sed -i '/^#*DefaultTasksMax=/d' /etc/systemd/system.conf

# Add new settings in the desired order
echo -e "# splunk modified value for file descriptor limit by user splunk\nDefaultLimitNOFILE=65000" | sudo tee -a /etc/systemd/system.conf
echo -e "# splunk modified value for max processes by user splunk\nDefaultLimitNPROC=16000" | sudo tee -a /etc/systemd/system.conf
echo -e "# splunk modified value for max tasks by user splunk\nDefaultTasksMax=80%" | sudo tee -a /etc/systemd/system.conf
```



# This will work for both comment and uncommented ones
# Backup the file
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.bak

# Uncomment and modify the settings, or add new ones if not found
Why Choose the this Approach?
- Flexibility: The c\ (change) command replaces the entire line if it exists, handling both commented and uncommented cases.
- Clearer Intent: It explicitly changes the whole line, which is more intuitive than using s/regex/replacement/ to modify it.
- No Partial Matches: It ensures only entire lines that match are replaced, reducing the risk of unwanted substitutions.
```sh
sudo sed -i 's/^#*DefaultLimitNOFILE=.*/# splunk modified value for file descriptor limit by user splunk\nDefaultLimitNOFILE=64000/' /etc/systemd/system.conf
sudo sed -i 's/^#*DefaultLimitNPROC=.*/# splunk modified value for max processes by user splunk\nDefaultLimitNPROC=16000/' /etc/systemd/system.conf
sudo sed -i 's/^#*DefaultTasksMax=.*/# splunk modified value for max tasks by user splunk\nDefaultTasksMax=80%/' /etc/systemd/system.conf
```

# This will work for both comment and uncommented ones
This will be the best
```sh
# Backup the original file
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.bak

# Update or add DefaultLimitNOFILE
sudo sed -i '/^#*DefaultLimitNOFILE=/c\# splunk modified value for file descriptor limit by user splunk\nDefaultLimitNOFILE=64000' /etc/systemd/system.conf

# Update or add DefaultLimitNPROC
sudo sed -i '/^#*DefaultLimitNPROC=/c\# splunk modified value for max processes by user splunk\nDefaultLimitNPROC=16000' /etc/systemd/system.conf

# Update or add DefaultTasksMax
sudo sed -i '/^#*DefaultTasksMax=/c\# splunk modified value for max tasks by user splunk\nDefaultTasksMax=80%' /etc/systemd/system.conf

```


# This delete the old ones and add new ones
```sh
sudo cp /etc/systemd/system.conf /etc/systemd/system.conf.bak

# Remove existing lines (commented or uncommented) to avoid duplicates
sudo sed -i '/^#*DefaultLimitNOFILE=/d' /etc/systemd/system.conf
sudo sed -i '/^#*DefaultLimitNPROC=/d' /etc/systemd/system.conf
sudo sed -i '/^#*DefaultTasksMax=/d' /etc/systemd/system.conf

# Add new settings with comments
echo "# splunk modified value for file descriptor limit by user splunk" | sudo tee -a /etc/systemd/system.conf
echo "DefaultLimitNOFILE=65000" | sudo tee -a /etc/systemd/system.conf

echo "# splunk modified value for max processes by user splunk" | sudo tee -a /etc/systemd/system.conf
echo "DefaultLimitNPROC=16000" | sudo tee -a /etc/systemd/system.conf

echo "# splunk modified value for max tasks by user splunk" | sudo tee -a /etc/systemd/system.conf
echo "DefaultTasksMax=80%" | sudo tee -a /etc/systemd/system.conf
```

What Happens in Each Case:

    Case: DefaultLimitNOFILE=64
        No substitution is made. This line will remain as is.

    Case: DefaultLimitNOFILE=128
        The line will be changed to DefaultLimitNOFILE=64000.

    Case: #DefaultLimitNOFILE=64
        Since the line is commented out, it doesn’t match the pattern /^DefaultLimitNOFILE=64/, so it will be replaced with DefaultLimitNOFILE=64000.
