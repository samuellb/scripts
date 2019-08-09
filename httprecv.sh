#!/bin/sh -eu
#
#  httprecv -- A simple shell script that receives a file over HTTP
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

if [ $# = 0 ]; then
    port=1111
    log WARNING "This script does NOT offer any security at all!"
    # Determine IP address, so we can show a IP
    # FIXME this is IPv4 only for now, but this script is intended for LAN use only
    # example.com = 93.184.216.34
    ip=$(ip route get 93.184.216.34 | grep -oE 'src [^ \t]+' | cut -c '5-' || true)
    urltext="${ip:+, URL is http://$ip:$port/}"
    log INFO "Listening at port $port$urltext"
    while nc.traditional -c "'$0' --internal-recv" -n -l -p "$port"; do
        true
    done
    exit
elif [ $# != 1 -o $1 != --internal-recv ]; then
    cat <<EOF
usage: $0

Listens on port 1111 and presents a file upload form. Files received will
be saved as "upload.bin" in the current directory.

Note: This script is intended for transferring files over a firewalled
network (or a secure point-to-point network link). It does not offer any
security at all, and it does not handle multiple users well.
EOF
    [ $1 = --help ]
    exit
fi

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

html_head() {
    title="$1"
    cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$title</title>
<style type="text/css">
html, body { background: Window; color: WindowText; font: 90% sans-serif; }
form { width: 25em; margin: 1em auto; padding: 1.5em; background: #fff; color: #000; }
h2 { border-bottom: 1px solid #000; }
h2.err { border: none; text-align: center; margin-top: 2em; }
h2.err::before { content: "⛔ "; }
input { padding: 0.5em; display: block; width: auto; }
#st { text-align: center; font-weight: bold; }
@media(max-width: 35em) {
  html, body, form { margin: 0; }
  form { background: transparent; color: inherit; }
  form, input { display: block; width: auto; }
  p { margin-bottom: 2em; }
  h2 { text-align: center; border: none; }
}
@media(pointer: coarse) {
  p { margin-bottom: 2em; }
  input { padding: 1.5em; }
}
@media(max-width: 10cm) {
  p, div, input { font-size: 100%; font-weight: bold; }
}
</style>
</head>
<body>
EOF
}

html_footer() {
cat <<EOF
</body>
</html>
EOF
}

resp_message() {
    respcode="$1"
    statusline="$2"
    resp_header "$respcode" "$statusline"
    html_head "$statusline"
    echo "<h2 class=\"err\">$statusline</h2>"
    html_footer
}

skip_headers() {
    while read line; do
        line=${line%$cr}
        [ -n "$line" ] || break
    done
}

read_multipart_boundary() {
    boundary="$1"
    read line
    line="${line%$cr}"
#echo "line: <$line>" >&2
#echo "mpb:  <--$boundary>" >&2
    if [ "$line" != "--$boundary" ]; then
        resp_message 400 "Bad request"
        echo "Error: Unexpected multipart boundary from client." >&2
        exit 1
    fi
}

read reqline
without_get=${reqline#GET }
without_get=${without_get#get }
without_head=${reqline#HEAD }
without_head=${without_head#head }
without_post=${reqline#POST }
without_post=${without_post#post }
if [ "${without_get}" != "$reqline" ]; then
    # GET request
    method=GET
    url_ver=$without_get
elif [ "${without_head}" != "$reqline" ]; then
    # HEAD request
    method=HEAD
    url_ver=$without_head
elif [ "${without_post}" != "$reqline" ]; then
    # GET request
    method=POST
    url_ver=$without_post
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

# Read headers
content_type=""
content_type_boundary=""
content_length=""
while read hdr; do
    hdr="${hdr%$cr}"
#echo "Read header: $hdr" >&2 # TODO remove
    [ -n "$hdr" ] || break
    hdrlower=$(printf %s "$hdr" | tr '[:upper:]' '[:lower:]')
    hdrname=$(printf %s "$hdrlower" | cut -d ':' -f 1 | tr -s " \t")
    hdrname=${hdrname% }
    hdrvalue=$(printf %s "$hdr" | cut -d ':' -f 2- | tr -s " \t")
    hdrvalue=${hdrvalue# }
#echo "Read header: <$hdrname> <$hdrvalue>" >&2 # TODO remove
    case "$hdrname" in
        content-length)
            tmp=$(printf %s "$hdrvalue" | tr -cd 0123456789)
            if [ "$tmp" = "$hdrvalue" ]; then
                content_length=$tmp
            fi
            unset tmp;;
        content-type)
            content_type=$(printf %s "$hdrvalue" | cut -d ';' -f 1 | tr -s ' \t' | tr '[:upper:]' '[:lower:]')
            remaining="$hdrvalue"
            while true; do
                remaining=$(printf %s "$remaining" | cut -sd ';' -f 2- | tr -s ' \t')
                remaining=${remaining# }
#                echo "remaining=<$remaining>" >&2
                [ -n "$remaining" ] || break
                if [ "${remaining#boundary=}" != "$remaining" ]; then
                    content_type_boundary=$(printf %s "${remaining#boundary=}" | cut -d ';' -f 1 | tr -s ' \t')
                fi
            done
            unset remaining;;
    esac
done
#echo "Done reading headers... CL=<$content_length> CT=<$content_type> CTB=<$content_type_boundary>" >&2 # TODO remove

if [ "$method" = HEAD ]; then
    cat <<EOF
HTTP/1.0 200 Ok$cr
Content-Type: text/html; charset=UTF-8$cr
X-Frame-Options: DENY$cr
X-Content-Type-Options: nosniff$cr
$cr
EOF
    exit
fi

# Handle POST
if [ "$method" = POST -a "$content_length" = 0 ]; then
    uploadstatus='Error: No data sent from browser'
elif [ "$method" = POST ]; then
    log INFO "Receiving file data ($content_length bytes)" # header is sanitized, so this is OK
    uploadstatus='Upload failed'
    #if [ -z "$content_length" ]; then
    #    resp_message 411 'Length Required'
    #    exit
    #fi
    if [ "$content_type" != multipart/form-data ]; then
        resp_message 415 'Unsupported form encoding'
        exit
    fi
    uploadstatus='Error: Upload was malformed'
    if [ -n "$content_length" ]; then
        #dd of=upload.mime bs=1 count="$content_length"
        dd bs=1 count="$content_length" 2>/dev/null
    else
        #cat > "$upload.mime"
        cat
    fi | {
        read_multipart_boundary "$content_type_boundary"
        part_length=""
        while read line; do
            line="${line%$cr}"
#echo "Multipart line: <$line>" >&2 # TODO remove
            [ -n "$line" ] || break
            hdrlower=$(printf %s "$hdr" | tr '[:upper:]' '[:lower:]')
            hdrname=$(printf %s "$hdrlower" | cut -d ':' -f 1 | tr -s " \t")
            hdrname=${hdrname% }
            hdrvalue=$(printf %s "$hdr" | cut -d ':' -f 2- | tr -s " \t")
            hdrvalue=${hdrvalue# }
#echo "Part header: <$hdrname> <$hdrvalue>" >&2 # TODO remove
            case "$hdrname" in
                content-length)
                    tmp=$(printf %s "$hdrvalue" | tr -cd 0123456789)
                    if [ "$tmp" = "$hdrvalue" ]; then
                        part_length=$tmp
                    fi
                    unset tmp;;
                content-disposition)
                    true # TODO
                    ;;
            esac
        done
#        if [ -z "$part_length" ]; then
#            # TODO
#            true
#        else
#            dd of=upload.bin bs=1 count="$part_length"
#        fi
#        read line
#echo "got line: $line" >&2
#        read_multipart_boundary "$content_type_boundary--"
        boundary_length=$(printf '%s' "RN--$boundary--RN" | wc -c) # include space for CR-LF before and after
        head -c -"$boundary_length" > upload.bin # FIXME this does not check the final multipart boundary
    }
    # TODO check for empty file and show a different message
    uploadstatus='File was uploaded successfully!'
    log INFO "$uploadstatus"
    unset line
else
    log INFO "Sending start page"
    uploadstatus=''
fi

title=${uploadstatus:-File upload}
statusdiv=${uploadstatus:+<div id="st">$uploadstatus</div>}
# Show form
resp_header 200 Ok
html_head "$title"
cat <<EOF
<form enctype="multipart/form-data" method="POST">
<h2>Upload file</h2>
<p><input type="file" name="filedata"></p>
<p><input type="submit" value="Upload file" onclick="if (document.getElementById) { var st = document.getElementById('st'); st.style.display = 'none'; } return true"></p>
$statusdiv
</form>
EOF
html_footer

