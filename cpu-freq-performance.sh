#!/bin/bash

sudo apt install cpufrequtils -y

subl /etc/systemd/system/set-cpufreq.service
# Paste the following:

[Unit]
Description=Set CPU governor to performance
After=multi-user.target
[Service]
Type=oneshot
ExecStart=/usr/bin/set-cpufreq.sh
RemainAfterExit=true
[Install]
WantedBy=multi-user.target

subl /usr/bin/set-cpufreq.sh
# Paste in:

#!/bin/bash
for cpu in /sys/devices/system/cpu/cpu[0-3]*; do
  cpufreq-set -c "${cpu##*/cpu}" -g performance
done

sudo chmod +x /usr/bin/set-cpufreq.sh

sudo systemctl daemon-reload
sudo systemctl enable set-cpufreq.service

# watch -n 1 "cat /proc/cpuinfo | grep MHz"

# In ubuntu settings, disable the search results characters, passwords, and clocks

# STEAM OPTIMIZATIONS:
# Head to steam settings
# Head to Account Details -> Preferences -> Disable Live Broadcasts
# Steam Settings -> Friends and Chat -> Disable "Enable Animated Avatars"
# Steam Settings -> Interface -> Disable run steam when my computer starts
# Steam Settings -> Interface -> Disable Enable smooth scrolling in web views
# Steam Settings -> Interface -> Disable GPU accelerated rendering
# Steam Settings -> Interface -> Disable hardware video decoding
# Steam Settings -> Library -> Enable Low Bandwidth mode, Low performance mode, and community center
# Steam Settings -> Downloads -> Disable allow downloads during gameplay
# Steam Settings -> Downloads -> Disable Game File Transfer over LAN
# Steam Settings -> Downloads -> Enable background vulkan processing
# Steam Settings -> Remote Play -> Disable Remote gameplay
# Steam Settings -> Broadcast -> Disable Broadcasting

# In properties of steam game, add in Launch Options:
# -high -nojoy
# (nojoy is only if never playing on controller)
