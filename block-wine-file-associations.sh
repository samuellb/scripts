#!/bin/sh
#
#  Copyright (c) 2015 Samuel Lidén Borell <samuel@kodafritt.se>
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


block() {
    if [ ! -d "$1" ]; then
        rm -f "$1"
        mkdir "$1"
        chmod 000 "$1"
        echo "Blocked: $1"
    else
        echo "Already blocked: $1"
    fi
}

exts="application art cdf chm cpl dib dll fif gif hlp hqx hta htc htm inf ini its jfif jpe js jse lnk mhtml mht msp png prf rat rtf sct shtml txt url wab vbe vbs vcf wri wsc wsf wsh xaml xbap xht xif xml"
for ext in $exts; do
    block ~/.local/share/mime/packages/x-wine-extension-$ext.xml
    block ~/.local/share/mime/application/x-wine-extension-$ext.xml
    block ~/.local/share/applications/wine-extension-$ext.desktop
done


