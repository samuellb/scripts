#!/bin/sh -eu
#
#  bwscan - script to scan a blackwhite A4 paper with 150dpi
#  Optimized for CanoScan LiDE 30
#
#  Copyright (c) 2021 Samuel Lidén Borell <samuel@kodafritt.se>
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



outfile="$1"

if [ -e "$outfile" ]; then
    echo "Output file $outfile already exists!\n" >&2
    exit 1
fi

tmpscan=$(mktemp tmp1scan-XXXXXXXX.pnm)
tmpconv=$(mktemp tmp2conv-XXXXXXXX.pnm)
tmpunp=$(mktemp tmp3unp-XXXXXXXX.pnm)

#scanimage --resolution 150 -x 210 -y 297 --calibration-cache=yes --mode Gray > "$tmpscan"
scanimage --resolution 150 -x 210 -y 297 --brightness -20% --contrast 20% --calibration-cache=yes --mode Gray > "$tmpscan"
#scanimage --resolution 150 -x 210 -y 297 --brightness -30% --contrast 40% --calibration-cache=yes --mode Gray > "$tmpscan"
#convert "$tmpscan" -gamma '0.5' -level-colors '75%,90%' "$tmpconv"
convert "$tmpscan" -gamma '0.3' -level-colors '80%,90%' -adaptive-sharpen 10x5 "$tmpconv"
#convert "$tmpscan" -gamma '0.5' -white-threshold '80%' -black-threshold '65%' "$tmpconv"
unpaper --overwrite "$tmpconv" "$tmpunp"
gpicview "$tmpunp" >/dev/null 2>&1 &
convert "$tmpunp" -alpha off -compress zip "$1"
# This gives *really* good compression
#convert "$tmpunp" -alpha off -monochrome -compress fax "$1"
