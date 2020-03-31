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

show_usage() {
    echo "usage: xgrant USER [trusted|untrusted] [timeout SECS]" >&2
}

show_help() {
    cat <<EOF
usage: xgrant USER [trusted|untrusted] [timeout SECS]

If not specified, only limited ("untrusted") access will be granted.
Some applications will not work correctly with untrusted access, or will
crash with an BadAccess error at certain points.

The timeout defaults to 60 seconds.

EOF
}

trustlevel=untrusted
timeout=60
if [ $# = 0 ]; then
    show_help
    exit 2
fi

username="$1"
shift
while [ $# -ge 1 ]; do
    case "$1" in
    trusted) trustlevel=trusted;;
    untrusted) trustlevel=untrusted;;
    timeout)
        shift
        timeout="$1";;
    *)
        echo "invalid parameter: $1"
        show_usage
        exit 2;;
    esac
    shift
done

userhome="$(getent passwd "$username" | cut -d : -f 6)"
if [ -z "$userhome" ]; then
    echo "$username: user not found" >&2
    exit 1
fi

authtemp="$(mktemp tmp.XXXXXXXXXX.xgrant --tmpdir)"
trap 'rm -f "$authtemp"' 0
xauth -f "$authtemp"  generate "$DISPLAY" MIT-MAGIC-COOKIE-1 "$trustlevel" timeout "$timeout"
#echo "$authtemp"
#cat "$authtemp"
sudo chown -- "$username" "$authtemp"
sudo mv -- "$authtemp" "$userhome/.Xauthority"
