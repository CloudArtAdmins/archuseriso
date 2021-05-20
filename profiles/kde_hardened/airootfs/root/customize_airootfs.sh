#!/usr/bin/env bash
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e -u

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist

# nsswitch.conf settings
# * Avahi : add 'mdns_minimal'
# * Winbind : add 'wins'
sed -i '/^hosts:/ {
        s/\(resolve\)/mdns_minimal \[NOTFOUND=return\] \1/
        s/\(dns\)$/\1 wins/ }' /etc/nsswitch.conf

# Nvidia driver setup
# either nvidia setup
# either optimus setup (default settings should work)
# either no setup
if grep -q 'nvidia' /version; then
    # Nvidia settings
    echo 'xrandr --setprovideroutputsource modesetting NVIDIA-0' >> /usr/share/sddm/scripts/Xsetup
    echo 'xrandr --auto --dpi 96' >> /usr/share/sddm/scripts/Xsetup
elif ! grep -q 'optimus' /version; then
    # Remove module settings
    rm /etc/modprobe.d/nvidia-drm.conf
fi

# Enable service when available
{ [[ -e /usr/lib/systemd/system/acpid.service                ]] && systemctl enable acpid.service;
  [[ -e /usr/lib/systemd/system/avahi-dnsconfd.service       ]] && systemctl enable avahi-dnsconfd.service;
  [[ -e /usr/lib/systemd/system/bluetooth.service            ]] && systemctl enable bluetooth.service;
  [[ -e /usr/lib/systemd/system/NetworkManager.service       ]] && systemctl enable NetworkManager.service;
  [[ -e /usr/lib/systemd/system/nmb.service                  ]] && systemctl enable nmb.service;
  [[ -e /usr/lib/systemd/system/cups.service                 ]] && systemctl enable cups.service;
  [[ -e /usr/lib/systemd/system/smb.service                  ]] && systemctl enable smb.service;
  [[ -e /usr/lib/systemd/system/systemd-timesyncd.service    ]] && systemctl enable systemd-timesyncd.service;
  [[ -e /usr/lib/systemd/system/winbind.service              ]] && systemctl enable winbind.service;
} > /dev/null 2>&1

# Set sddm display-manager
ln -s /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G 'wheel' -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers

# disable systemd-networkd.service
# we have NetworkManager for managing network interfaces
[[ -e /etc/systemd/system/multi-user.target.wants/systemd-networkd.service ]] && rm /etc/systemd/system/multi-user.target.wants/systemd-networkd.service
[[ -e /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service ]] && rm /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
[[ -e /etc/systemd/system/sockets.target.wants/systemd-networkd.socket ]] && rm /etc/systemd/system/sockets.target.wants/systemd-networkd.socket

# extra zsh settings for live user
echo "
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh
zstyle ':completion:*:*:*:default' menu yes select search #add interactive and searchable menu to tab completions
bindkey \"^[[3~\" delete-char # DELETE key removes character in front (opposite of backspace)
bindkey \^U backward-kill-line # CTRL + U delets all to left        
bindkey \"^[[1;5C\" forward-word # CTRL + right arrow key jump
bindkey \"^[[1;5D\" backward-word # CTRL + left arrow key jump
bindkey '^[[Z' autosuggest-accept # Accept suggestion from zsh-autosuggest
bindkey '^ ' autosuggest-execute # Execute suggestion from zsh-autosuggest
bindkey \"\$terminfo[kcuu1]\" history-substring-search-up # Up arrow key searches for similar commands to what was typed
bindkey \"\$terminfo[kcud1]\" history-substring-search-down # Down arrow key searches for similar commands to what was typed" >> /home/live/.zshrc

ln -s /usr/bin/firejail /usr/local/bin/flameshot 
ln -s /usr/bin/firejail /usr/local/bin/freshclam 
ln -s /usr/bin/firejail /usr/local/bin/lomath 
ln -s /usr/bin/firejail /usr/local/bin/hexchat 
ln -s /usr/bin/firejail /usr/local/bin/mpg123 
ln -s /usr/bin/firejail /usr/local/bin/ffprobe 
ln -s /usr/bin/firejail /usr/local/bin/mpg123-id3dump 
ln -s /usr/bin/firejail /usr/local/bin/vlc 
ln -s /usr/bin/firejail /usr/local/bin/loweb 
ln -s /usr/bin/firejail /usr/local/bin/pavucontrol 
ln -s /usr/bin/firejail /usr/local/bin/clamdscan 
ln -s /usr/bin/firejail /usr/local/bin/soffice 
ln -s /usr/bin/firejail /usr/local/bin/localc 
ln -s /usr/bin/firejail /usr/local/bin/fractal 
ln -s /usr/bin/firejail /usr/local/bin/keepassxc-cli 
ln -s /usr/bin/firejail /usr/local/bin/ffplay 
ln -s /usr/bin/firejail /usr/local/bin/firefox 
ln -s /usr/bin/firejail /usr/local/bin/torbrowser-launcher 
ln -s /usr/bin/firejail /usr/local/bin/lofromtemplate 
ln -s /usr/bin/firejail /usr/local/bin/okular 
ln -s /usr/bin/firejail /usr/local/bin/img2txt 
ln -s /usr/bin/firejail /usr/local/bin/strings 
ln -s /usr/bin/firejail /usr/local/bin/loimpress 
ln -s /usr/bin/firejail /usr/local/bin/pdftotext 
ln -s /usr/bin/firejail /usr/local/bin/gapplication 
ln -s /usr/bin/firejail /usr/local/bin/whois 
ln -s /usr/bin/firejail /usr/local/bin/feh 
ln -s /usr/bin/firejail /usr/local/bin/wget 
ln -s /usr/bin/firejail /usr/local/bin/lobase 
ln -s /usr/bin/firejail /usr/local/bin/lodraw 
ln -s /usr/bin/firejail /usr/local/bin/patch 
ln -s /usr/bin/firejail /usr/local/bin/clamdtop 
ln -s /usr/bin/firejail /usr/local/bin/cvlc 
ln -s /usr/bin/firejail /usr/local/bin/enchant-lsmod-2 
ln -s /usr/bin/firejail /usr/local/bin/keepassxc 
ln -s /usr/bin/firejail /usr/local/bin/deluge 
ln -s /usr/bin/firejail /usr/local/bin/ffmpeg 
ln -s /usr/bin/firejail /usr/local/bin/ssh 
ln -s /usr/bin/firejail /usr/local/bin/loffice 
ln -s /usr/bin/firejail /usr/local/bin/mpg123-strip 
ln -s /usr/bin/firejail /usr/local/bin/qt-faststart 
ln -s /usr/bin/firejail /usr/local/bin/lynx 
ln -s /usr/bin/firejail /usr/local/bin/lowriter 
ln -s /usr/bin/firejail /usr/local/bin/nslookup 
ln -s /usr/bin/firejail /usr/local/bin/dig 
ln -s /usr/bin/firejail /usr/local/bin/secret-tool 
ln -s /usr/bin/firejail /usr/local/bin/keepassxc-proxy 
ln -s /usr/bin/firejail /usr/local/bin/libreoffice 
ln -s /usr/bin/firejail /usr/local/bin/enchant-2 
ln -s /usr/bin/firejail /usr/local/bin/host 
ln -s /usr/bin/firejail /usr/local/bin/youtube-dl 
ln -s /usr/bin/firejail /usr/local/bin/conplay 
ln -s /usr/bin/firejail /usr/local/bin/Xephyr 
ln -s /usr/bin/firejail /usr/local/bin/display 
ln -s /usr/bin/firejail /usr/local/bin/clamscan 
ln -s /usr/bin/firejail /usr/local/bin/out123 
ln -s /usr/bin/firejail /usr/local/bin/thunderbird 

freshclam
systemctl enable clamav-daemon.service
