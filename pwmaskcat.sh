#!/bin/sh -eu
#
#  pwmaskcat -- Shows files with passwords dimmed but still possible to copy
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


esc='\x1B'
# any except space and control characters
any='[[:graph:]]'
alt1="$any*[a-z]$any*[A-Z]$any*"
alt2="$any*[A-Z]$any*[0-9]$any*"
alt3="$any*[0-9]$any*[a-z]$any*"
alt3="$any*[\\x21-\\x40]$any*[a-z]$any*"
match="($alt1|$alt2|$alt3)"
# black (makes it impossible to see what you have selected)
#replacement="${esc}[30;40m\1$esc[0m"
# light gray on gray, with blink + underscore
replacement="${esc}[37;47;1;4;5m\\1${esc}[0m"
#
#replacement="${esc}[37;1m\\1${esc}[0m"

regex="s/$match/$replacement/g"
#echo "$regex"
sed -E -- "$regex" "$@"
