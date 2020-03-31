#!/bin/sh -eu
#
#  simplefj -- Runs a command with firejail with almost everything locked down
#
#  Copyright © 2020 Samuel Lidén Borell <samuel@kodafritt.se>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#



base_blacklist="--blacklist=/srv --blacklist=/run/acpid.pid --blacklist=/run/acpid.socket --blacklist=/run/alsa --blacklist=/run/avahi-daemon --blacklist=/run/blkid --blacklist=/run/boltd --blacklist=/run/charon.ctl --blacklist=/run/charon.pid --blacklist=/run/console-setup --blacklist=/run/crond.pid --blacklist=/run/crond.reboot --blacklist=/run/cryptsetup --blacklist=/run/dbus --blacklist=/run/dhclient-wlp2s0.pid --blacklist=/run/dmeventd-client --blacklist=/run/dmeventd-server --blacklist=/run/docker.pid --blacklist=/run/docker.sock --blacklist=/run/ebtables.lock --blacklist=/run/fsck --blacklist=/run/gdm3 --blacklist=/run/gdm3.pid --blacklist=/run/initctl --blacklist=/run/initramfs --blacklist=/run/laptop-mode-tools --blacklist=/run/libvirt --blacklist=/run/libvirtd.pid --blacklist=/run/lock --blacklist=/run/log --blacklist=/run/lvmg --blacklist=/run/lvmetad.pid --blacklist=/run/lxc --blacklist=/run/mlocate.daily.lock --blacklist=/run/mysqld  --blacklist=/run/network --blacklist=/run/NetworkManager --blacklist=/run/openvpn --blacklist=/run/openvpn-client --blacklist=/run/openvpn-server --blacklist=/run/plymouth --blacklist=/run/pppconfig --blacklist=/run/rsyslogd.pid --blacklist=/run/sendsigs.omit.d --blacklist=/run/snapd-snap.socket --blacklist=/run/snapd.socket --blacklist=/run/spice-vdagentd --blacklist=/run/starter.charon.pid --blacklist=/run/sudo  --blacklist=/run/systemd --blacklist=/run/thermald --blacklist=/run/tmpfiles.d --blacklist=/run/ubuntu-fan --blacklist=/run/udev --blacklist=/run/udisks2 --blacklist=/run/unattended-upgrades.lock --blacklist=/run/user/120 --blacklist=/run/utmp  --blacklist=/run/uuidd --blacklist=/run/virtlogd.pid --blacklist=/run/wpa_supplicant --blacklist=/run/xl2tpd --blacklist=/run/xl2tpd.pid --blacklist=/run/xtables.sock --blacklist=/etc/passwd- --blacklist=/etc/group- --blacklist=/etc/apparmor.d --blacklist=/etc/subuid --blacklist=/etc/subgid --blacklist=/var/cache/debconf --blacklist=/run/cups --blacklist=/run/user/1000"

exec firejail --noprofile --quiet --caps.drop=all --disable-mnt \
    --hostname=restricted --ipc-namespace --machine-id --net=none --nice=2 \
    --no3d --nodbus --nodvd --nogroups --noroot --nonewprivs --nosound \
    --noautopulse --notv --nou2f --novideo --private --private-dev \
    $base_blacklist --private-tmp --shell=/bin/sh --x11=none -- "$@" \
