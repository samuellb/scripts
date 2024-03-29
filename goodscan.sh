#!/bin/sh -eu
#
#  goodscan - script to scan a A4 paper in color with 300dpi
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

scanimage --resolution 300 -x 210 -y 305 --brightness -30 --contrast 30 --calibration-cache=yes > "$tmpscan"
convert "$tmpscan" -level '30%,70%,1.2' -adaptive-sharpen 10x5 -alpha off -compress zip -page a4 "$1"
evince "$1"
