#!/bin/sh -eu
#
#  xgrant -- Grants another user trusted or untrusted access to your X session
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

trustlevel=untrusted
if [ $# = 2 ]; then
    case "$2" in
    trusted) trustlevel=trusted;;
    untrusted) trustlevel=untrusted;;
    *)
        echo 'trust level must be either "trusted" or "untrusted".'
        echo "usage: xgrant USER [trusted|untrusted]" >&2
        exit 2;;
    esac
elif [ $# != 1 ]; then
    cat <<EOF
usage: xgrant USER [trusted|untrusted]

If not specified, only limited ("untrusted") access will be granted.
Some applications will not work correctly with untrusted access, or will
crash with an BadAccess error at certain points.
EOF
    exit 2
fi

username="$1"
userhome="$(getent passwd "$username" | cut -d : -f 6)"
if [ -z "$userhome" ]; then
    echo "$username: user not found" >&2
    exit 1
fi

authtemp="$(tempfile -p temp -s .xgrant)"
trap 'rm -f "$authtemp"' 0
xauth -f "$authtemp"  generate "$DISPLAY" MIT-MAGIC-COOKIE-1 "$trustlevel"
#echo "$authtemp"
#cat "$authtemp"
sudo chown -- "$username" "$authtemp"
sudo mv -- "$authtemp" "$userhome/.Xauthority"