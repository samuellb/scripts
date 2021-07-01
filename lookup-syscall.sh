#!/bin/sh -eu
#
#  lookup-syscall -- Looks up Linux x86-64 syscall names from numeric IDs
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


export LC_ALL=C.UTF-8
if [ $# = 0 ]; then
    #tail -n 100 /var/log/kern.log | grep -voE 'sig=[0-9]+ arch=[0-9a-f]+ syscall=[0-9]+'
    #syscall=$(tail -n 100 /var/log/kern.log | grep -voE 'sig=[0-9]+ arch=[0-9a-f]+ syscall=[0-9]+' | tail -n 1 | cut -d = -f 4)
    syscalls=$(sudo dmesg | grep -oE 'sig=[0-9]+ arch=[0-9a-f]+ syscall=[0-9]+' | tail -n 4 | cut -d = -f 4)
else
    syscalls=$*
fi


for syscall in $syscalls; do
    printf "%s = " "$syscall"
    grep -E "_NR_[A-Za-z_0-9]+ $syscall\$" /usr/include/x86_64-linux-gnu/asm/unistd_64.h | sed 's/#define __NR_//' | cut -d ' ' -f 1
done
