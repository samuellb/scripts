#!/bin/sh
#
#  gejava -- finds Java source files and opens them in gedit
#
#  Copyright (c) 2013 Samuel Lidén Borell <samuel@kodafritt.se>
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

if [ -z "$1" ]; then
    echo "usage: $0 PATTERN..."
    echo
    echo "Finds Java source files and opens them in gedit."
    exit 1
fi

patterns="$*"

oldifs="$IFS"
#IFS="`printf '\\\0'`"
#IFS="`printf '\\n'`"
# FIXME ugly!
space=""
error=0
while [ $# != 0 ]; do
    addfiles="`find -name "$1.java" | grep -vE '(.svn|src-temp)'`"
    if [ -n "$addfiles" ]; then
        files="$files$space$addfiles"
        space=" "
    else
        echo "$0: $1: no matches" >&2
        error=1
    fi
    shift
done
#files=`find -name "$1.java" -print0`

#echo "<$files>"
if [ -n "$files" ]; then
    #IFS="`printf ' \n\0'`"
    #IFS="$oldifs"
    gedit $files
    #echo $files
    exit $error
else
    exit 1
fi

