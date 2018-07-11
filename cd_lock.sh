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

if [ $# = 0 ] || [ "$1" = "lock" ]; then
    state=on
elif [ "$1" = unlock ]; then
    state=off
else
    cat >&2 <<EOF
$0: [lock|unlock]

Locks (default) or unlocks the CD/DVD drive (or other ejectable drive).

For this command to work, you might have to configure udev first,
which can be done with the steps below (step might vary between systems):

  1. sudo cp /lib/udev/rules.d/60-cdrom_id.rules /etc/udev/rules.d/
  2. edit /etc/udev/rules.d/60-cdrom_id.rules and remove (or comment out)
     DISK_EJECT_REQUEST
  3. save the file. the changes should take effect immediately

See the "eject" command for technical details.
EOF
    case "$1" in
    --help|-h) exit;;
    *) exit 2;;
    esac
fi

exec eject -i "$state"

