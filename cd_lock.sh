#!/bin/sh -eu
#
#  cd_lock -- Locks or unlocks CD/DVD trays or other ejectable drives
#
#  Copyright (c) 2018 Samuel Lidén Borell <samuel@kodafritt.se>
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

cmd="${1:-lock}"
procdevlock() {
    local procfile=/proc/sys/dev/cdrom/lock
    if [ -w "$procfile" ]; then
        echo "$1" > "$procfile"
    elif type sudo > /dev/null 2>&1 && [ -e /etc/sudoers ]; then
        sudo su -c "echo '$1' > '$procfile'"
    else
        echo "$0: $procfile is not writable. You may have to run the command as root." >&2
        false
    fi
}

case "$cmd" in
lock)
    exec eject -i on;;
unlock)
    exec eject -i off;;
hardlock)
    echo "Locking using /proc filesystem"
    procdevlock 1;;
hardunlock)
    echo "Unlocking using /proc filesystem"
    procdevlock 0;;
*)
    cat >&2 <<EOF
$0: [lock|unlock|hardlock|hardunlock]

Locks (default) or unlocks the CD/DVD drive (or other ejectable drive).

The "lock" and "unlock" commands use the "eject" command internally. For
this to work, you might have to configure udev first, which can be done
with the steps below (step might vary between systems):

  1. sudo cp /lib/udev/rules.d/60-cdrom_id.rules /etc/udev/rules.d/
  2. edit /etc/udev/rules.d/60-cdrom_id.rules and remove (or comment out)
     DISK_EJECT_REQUEST
  3. save the file. the changes should take effect immediately

As an alternative, you may also use the "hardlock" or "hardunlock"
subcommands, which use the /proc filesystem to lock the drive. This
typically requires root. cd_lock will attempt to use "sudo" to gain root,
if available.
EOF
    if [ "$cmd" != --help -a "$cmd" != -h ]; then
         exit 2
    fi;;
esac
