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

# Nvidia GPU proprietary driver setup
# either nvidia only setup
# either optimus, both graphics devices setup
# either no nvidia driver installed
if $(pacman -Qsq '^nvidia$' > /dev/null 2>&1); then
    # checking optimus option
    if [[ -z "${AUI_OPTIMUS:-}" ]]; then
        # No optimus option, nvidia driver only setup
        sed -i 's|^#\(display-setup-script=\)$|\1/etc/lightdm/display_setup.sh|' /etc/lightdm/lightdm.conf
    else
        # optimus option setup, no specific lightdm configuration required
        rm /etc/lightdm/display_setup.sh
    fi
else
    # nvidia not installed, removing configuration files
    rm /etc/lightdm/display_setup.sh /etc/modprobe.d/nvidia-drm.conf
fi

# Lightdm display-manager
# * live user autologin
# * Adwaita theme
# * background color
sed -i 's/^#\(autologin-user=\)$/\1live/
        s/^#\(autologin-session=\)$/\1cinnamon/' /etc/lightdm/lightdm.conf
sed -i 's/^#\(background=\)$/\1#232627/
        s/^#\(theme-name=\)$/\1Adapta/
        s/^#\(icon-theme-name=\)$/\1Adapta/' /etc/lightdm/lightdm-gtk-greeter.conf

# missing link pointing to default vncviewer
ln -s /usr/bin/gvncviewer /usr/local/bin/vncviewer

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

# Set lightdm display-manager
ln -s /usr/lib/systemd/system/lightdm.service /etc/systemd/system/display-manager.service

# Add live user
# * groups member
# * user without password
# * sudo no password settings
useradd -m -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,sys,video,wheel" -s /bin/zsh live
sed -i 's/^\(live:\)!:/\1:/' /etc/shadow
sed -i 's/^#\s\(%wheel\s.*NOPASSWD\)/\1/' /etc/sudoers

# Create autologin group
# add live to autologin group
groupadd -r autologin
gpasswd -a live autologin

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

ln -s /usr/local/bin/flameshot /usr/bin/firejail
ln -s /usr/local/bin/freshclam /usr/bin/firejail
ln -s /usr/local/bin/lomath /usr/bin/firejail
ln -s /usr/local/bin/hexchat /usr/bin/firejail
ln -s /usr/local/bin/mpg123 /usr/bin/firejail
ln -s /usr/local/bin/ffprobe /usr/bin/firejail
ln -s /usr/local/bin/mpg123-id3dump /usr/bin/firejail
ln -s /usr/local/bin/vlc /usr/bin/firejail
ln -s /usr/local/bin/loweb /usr/bin/firejail
ln -s /usr/local/bin/pavucontrol /usr/bin/firejail
ln -s /usr/local/bin/clamdscan /usr/bin/firejail
ln -s /usr/local/bin/soffice /usr/bin/firejail
ln -s /usr/local/bin/localc /usr/bin/firejail
ln -s /usr/local/bin/fractal /usr/bin/firejail
ln -s /usr/local/bin/keepassxc-cli /usr/bin/firejail
ln -s /usr/local/bin/ffplay /usr/bin/firejail
ln -s /usr/local/bin/firefox /usr/bin/firejail
ln -s /usr/local/bin/torbrowser-launcher /usr/bin/firejail
ln -s /usr/local/bin/lofromtemplate /usr/bin/firejail
ln -s /usr/local/bin/okular /usr/bin/firejail
ln -s /usr/local/bin/img2txt /usr/bin/firejail
ln -s /usr/local/bin/strings /usr/bin/firejail
ln -s /usr/local/bin/loimpress /usr/bin/firejail
ln -s /usr/local/bin/pdftotext /usr/bin/firejail
ln -s /usr/local/bin/gapplication /usr/bin/firejail
ln -s /usr/local/bin/whois /usr/bin/firejail
ln -s /usr/local/bin/feh /usr/bin/firejail
ln -s /usr/local/bin/wget /usr/bin/firejail
ln -s /usr/local/bin/lobase /usr/bin/firejail
ln -s /usr/local/bin/lodraw /usr/bin/firejail
ln -s /usr/local/bin/patch /usr/bin/firejail
ln -s /usr/local/bin/clamdtop /usr/bin/firejail
ln -s /usr/local/bin/cvlc /usr/bin/firejail
ln -s /usr/local/bin/enchant-lsmod-2 /usr/bin/firejail
ln -s /usr/local/bin/keepassxc /usr/bin/firejail
ln -s /usr/local/bin/deluge /usr/bin/firejail
ln -s /usr/local/bin/ffmpeg /usr/bin/firejail
ln -s /usr/local/bin/ssh /usr/bin/firejail
ln -s /usr/local/bin/loffice /usr/bin/firejail
ln -s /usr/local/bin/mpg123-strip /usr/bin/firejail
ln -s /usr/local/bin/qt-faststart /usr/bin/firejail
ln -s /usr/local/bin/lynx /usr/bin/firejail
ln -s /usr/local/bin/lowriter /usr/bin/firejail
ln -s /usr/local/bin/nslookup /usr/bin/firejail
ln -s /usr/local/bin/dig /usr/bin/firejail
ln -s /usr/local/bin/secret-tool /usr/bin/firejail
ln -s /usr/local/bin/keepassxc-proxy /usr/bin/firejail
ln -s /usr/local/bin/libreoffice /usr/bin/firejail
ln -s /usr/local/bin/enchant-2 /usr/bin/firejail
ln -s /usr/local/bin/host /usr/bin/firejail
ln -s /usr/local/bin/youtube-dl /usr/bin/firejail
ln -s /usr/local/bin/conplay /usr/bin/firejail
ln -s /usr/local/bin/Xephyr /usr/bin/firejail
ln -s /usr/local/bin/display /usr/bin/firejail
ln -s /usr/local/bin/clamscan /usr/bin/firejail
ln -s /usr/local/bin/out123 /usr/bin/firejail
ln -s /usr/local/bin/thunderbird /usr/bin/firejail

freshclam
systemctl enable clamav-daemon.service
