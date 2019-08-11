#!/bin/sh -eu
#
#  httpshare -- A simple shell script that shares a file over HTTP
#
#  Copyright (c) 2019 Samuel Lidén Borell <samuel@kodafritt.se>
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

export LC_ALL=C.UTF-8

log() {
    level="$1"
    message="$2"
    date="$(date --rfc-3339=seconds)"
    printf '%s\n' "$date [$level] $message" >&2
}

if [ $# = 0 ] || [ "$1" = --help ]; then
    cat <<EOF
usage: $0 FILE

Listens on port 1111 and sends the given file to each HTTP client
that connects. The HTTP client can be, for example, a browser, or
a download utility such as curl or wget.

Note: This script is intended for transferring files over a firewalled
network (or a secure point-to-point network link). It does not offer any
security at all, and it does not handle concurrent users.
EOF
    [ $# = 1 ]
    exit
fi

if [ $1 != --internal-send ]; then
    if [ "$1" = -- ]; then
        shift
    fi
    port=1111
    log WARNING "This script does NOT offer any security at all!"
    # Determine IP address, so we can show a IP
    # FIXME this is IPv4 only for now, but this script is intended for LAN use only
    # example.com = 93.184.216.34
    ip=$(ip route get 93.184.216.34 | grep -oE 'src [^ \t]+' | cut -c '5-' || true)
    urltext="${ip:+, URL is http://$ip:$port/}"
    log INFO "Listening at port $port$urltext"
    log INFO "Sharing file \"$1\""
    while nc.traditional -c "'$0' --internal-send '$1'" -n -l -p "$port"; do
        true
    done
    exit
fi

log INFO "Client connected"
cr=$(printf '\r')

resp_header() {
    respcode="$1"
    statusline="$2"
    cat <<EOF
HTTP/1.0 $respcode $statusline$cr
Content-Type: text/html; charset=UTF-8$cr
X-Frame-Options: DENY$cr
X-Content-Type-Options: nosniff$cr
Content-Security-Policy: default-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'$cr
$cr
EOF
}

resp_message() {
    respcode="$1"
    statusline="$2"
    resp_header "$respcode" "$statusline"
    cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type; charset=UTF-8">
<title>$statusline</title>
</head>
<body>
<h2>$statusline</h2>
</body>
</html>
EOF
}

skip_headers() {
    while read line; do
        line=${line%$cr}
        [ -n "$line" ] || break
    done
}

read reqline
without_get=${reqline#GET }
without_get=${without_get#get }
without_head=${reqline#HEAD }
without_head=${without_head#head }
if [ "${without_get}" != "$reqline" ]; then
    # GET request
    method=GET
    url_ver=$without_get
elif [ "${without_head}" != "$reqline" ]; then
    # HEAD request
    method=HEAD
    url_ver=$without_head
else
    skip_headers
    resp_message 405 'Method not allowed'
    exit
fi

if [ "${url_ver#/ }" = "$url_ver" ]; then
    skip_headers
    resp_message 404 'Incorrect URL'
    exit
fi

# TODO parse range requests?
skip_headers

filename=$2
filesize=$(stat -c %s "$filename")
basename=$(basename "$filename")

# FIXME long filenames are not sent in accordance to RFC-2183
cat <<EOF
HTTP/1.0 200 Ok$cr
Content-Type: application/octet-stream; charset=UTF-8$cr
Content-Length: $filesize$cr
Content-Disposition: attachment; filename="$basename"$cr
X-Frame-Options: DENY$cr
X-Content-Type-Options: nosniff$cr
$cr
EOF

if [ "$method" = HEAD ]; then
    exit
fi

log INFO "Sending file \"$filename\""
cat "$filename"
log INFO "Successfully sent file."
