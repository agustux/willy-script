#!/bin/bash

sudo apt update && sudo apt full-upgrade -y
sudo apt autoremove --purge -y
sudo apt autoclean -y
sudo apt clean

# Cleaning up Swapfile for max space:
sudo swapoff -a -v
sudo rm /swap.img
sudo sed -i '/^\/swap\.img/s/^/#/' /etc/fstab

# Misc:
sudo add-apt-repository multiverse -y
sudo apt update
sudo apt install curl git vim exfat-fuse gnome-tweaks ufw vlc gnome-shell-extensions gnome-shell-extension-manager cpufrequtils preload -y

# Randomizing MAC address:
sudo tee /etc/NetworkManager/conf.d/mac-randomize.conf > /dev/null <<EOF
[device-mac-randomization]
wifi.scan-rand-mac-address=yes

[connection-mac-randomization]
ethernet.cloned-mac-address=random
wifi.cloned-mac-address=random
EOF

sudo chmod 0644 /etc/NetworkManager/conf.d/mac-randomize.conf

# Purging Snap:
for pkg in $(snap list | awk 'NR>1 {print $1}'); do
  sudo snap remove --purge "$pkg" || true
  sleep 2
done

sudo systemctl disable --now snapd
sudo apt purge snapd -y
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

sudo chown root:root /etc/apt/preferences.d/no-snap.pref

sudo apt autoremove --purge -y

# Sublime Text:
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
sudo apt update
sudo apt install sublime-text -y

# Brave:
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
sudo curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
sudo apt update
sudo apt install brave-browser -y

# Bluetooth AAC codec stuff:
sudo add-apt-repository ppa:aglasgall/pipewire-extra-bt-codecs -y
sudo apt update && sudo apt full-upgrade -y
sudo systemctl enable bluetooth.service
sudo rfkill unblock bluetooth
sudo sed -i 's/^#\?ControllerMode = dual/ControllerMode = bredr/' /etc/bluetooth/main.conf
sudo sed -i '/^\[BR\]/i AutoConnect=true' /etc/bluetooth/main.conf
sudo /etc/init.d/bluetooth restart

sudo tee -a /usr/share/wireplumber/wireplumber.conf > /dev/null << 'EOF'
monitor.bluez.properties = {
  bluez5.codecs = [ sbc sbc_xq aac ]
}
EOF
# sudo systemctl restart wireplumber

# ProtonVPN:
wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
echo "0b14e71586b22e498eb20926c48c7b434b751149b1f2af9902ef1cfe6b03e180 protonvpn-stable-release_1.0.8_all.deb" | sha256sum --check -
sudo apt install proton-vpn-gnome-desktop -y
sudo apt install libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator -y
rm protonvpn-stable-release_1.0.8_all.deb

# GNOME Extensions:
array=( https://extensions.gnome.org/extension/3193/blur-my-shell/
https://extensions.gnome.org/extension/6655/openweather/
https://extensions.gnome.org/extension/6670/bluetooth-battery-meter/ )

for i in "${array[@]}"
do
    EXTENSION_ID=$(curl -s $i | grep -oP 'data-uuid="\K[^"]+')
    VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=$EXTENSION_ID" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
    wget -O ${EXTENSION_ID}.zip "https://extensions.gnome.org/download-extension/${EXTENSION_ID}.shell-extension.zip?version_tag=$VERSION_TAG"
    gnome-extensions install --force ${EXTENSION_ID}.zip
    if ! gnome-extensions list | grep --quiet ${EXTENSION_ID}; then
        busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${EXTENSION_ID}
    fi
    gnome-extensions enable ${EXTENSION_ID}
    rm ${EXTENSION_ID}.zip
done

gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.ding show-home false
gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false

# Steam:
wget https://repo.steampowered.com/steam/archive/stable/steam_latest.deb
sudo apt install ./steam_latest.deb -y
rm steam_latest.deb

# Discord:
wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
sudo apt install ./discord.deb -y
rm discord.deb

# UxPlay:
sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav uxplay -y

# Greenlight (xcloud linux wrapper)
curl -LO "$(curl -s https://api.github.com/repos/unknownskl/greenlight/releases/latest | jq -r '.assets[] | select(.name | contains("_amd64.deb")) | .browser_download_url')"
sudo apt install ./greenlight*.deb -y
rm greenlight*.deb

steam

rm -rf Desktop/*