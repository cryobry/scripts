#!/usr/bin/env bash
# Fedora 41 setup script

# Get some OS details
# [[ -e /etc/os-release ]] && source /etc/os-release

# Add external repos
sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/shells:zsh-users:zsh-completions/Fedora_Rawhide/shells:zsh-users:zsh-completions.repo
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

# Add/remove packages
sudo dnf remove -y abrt rhythmbox gnome-software spice-vdagent open-vm-tools-desktop orca anaconda-live gnome-initial-setup
sudo dnf install -y \
       rpmfusion-free-release \
       zsh zsh-completions ShellCheck \
       btrbk btrfsmaintenance \
       vim htop remmina calibre pinta toolbox code gnome-tweaks \
       wl-clipboard syncthing profile-sync-daemon \
       python3-virtualenv python3-virtualenvwrapper nautilus-python gettext \
       setroubleshoot
        
# Use zsh as default shell
chsh -s "$(which zsh)"

# Enable profile-sync-daemon for the user
systemctl --user enable --now psd

# Enable automatic system updates
sudo systemctl enable --now dnf5-automatic.timer

# Make btrfs subvolumes
sudo btrfs sub create ~/media/music
sudo btrfs sub create ~/media/tv
sudo btrfs sub create ~/media/pictures
sudo btrfs sub create ~/media/ebooks
sudo btrfs sub create ~/media/movies
sudo btrfs sub create ~/media/podcasts

# Create links
ln -s ~/media/music ~/music
ln -s ~/documents/develop ~/develop
ln -s ~/.local/bin ~/bin
ln -s ~/devices/phone/podcasts ~/media/podcasts
ln -s ~/develop/scripts/share-link ~/.local/share/nautilus/scripts/

# Allow some commands to invoke sudo without a password
echo "bryan ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper, /usr/sbin/btrfs, /usr/bin/journalctl, /usr/bin/dnf, /usr/bin/fwupdmgr, /usr/bin/dmesg" | sudo tee -a /etc/sudoers > /dev/null

# Use full location in nautilus
gsettings set org.gnome.nautilus.preferences always-use-location-entry true

# Increase scrollback limit for gnome-console
kgx --set-scrollback 100000000

# btrbk
# sudo ln -s ~/.config/btrbk/btrbk.conf /etc/btrbk/btrbk.conf
# ssh-keygen -t ed25519 -f ~/.config/btrbk/id_ed25519
#[[ ! -d "/etc/btrbk/ssh/" ]] && sudo mkdir -p /etc/btrbk/ssh
#sudo ln -s ~/.config/btrbk/id_ed25519 /etc/btrbk/ssh/id_ed25519

# Firefox
# mousewheel.acceleration.factor 20
# mousewheel.acceleration.start 2
# gfx.webrender.all true
# browser.tabs.insertAfterCurrent true
# browser.ctrlTab.sortByRecentlyUsed = true

# Create battery charging threshold service
sudo bash -c "cat <<-EOF > /etc/systemd/system/set-battery-charge-threshold.service
       [Unit]
       Description=Set battery charge thresholds
       After=multi-user.target
       StartLimitBurst=0

       [Service]
       Type=oneshot
       Restart=on-failure
       RemainAfterExit=yes
       ExecStart=/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_start_threshold; echo 90 > /sys/class/power_supply/BAT0/charge_control_end_threshold'
       ExecStop=/bin/bash -c 'echo 100 > /sys/class/power_supply/BAT0/charge_control_end_threshold; echo 99 > /sys/class/power_supply/BAT0/charge_control_start_threshold'

       [Install]
       WantedBy=multi-user.target
EOF"
sudo systemctl daemon-reload &&
sudo systemctl enable --now set-battery-charge-threshold.service

# Increase max_user_watches for VSCode
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/local.conf > /dev/null
sudo systemctl restart systemd-sysctl.service

# Install clone dirs
git -C ~/.local/bin clone https://git.bryanroessler.com/bryan/installJRMC.git -b dev
git -C ~/.local/bin clone https://git.bryanroessler.com/bryan/openwrtbuilder.git -b dev

