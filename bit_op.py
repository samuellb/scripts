#!/usr/bin/env python3
#
#  bit_op.py -- Performs bitwise operations on files
#
#  Copyright (c) 2014 Samuel Lidén Borell <samuel@kodafritt.se>
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


def bit_op(op, a, b):
    """Performs a bitwise operation ('|' or '&'). It is performed
       in-place on the byte-string a, which is extended if necessary."""
    initval = 0xFF if op == '&' else 0x00
    if len(b) > len(a):
        #a += bytearray(len(b) - len(a))
        a.extend([initval for i in range(len(b) - len(a))])
    if op == '|':
        for i in range(len(a)):
            a[i] |= b[i]
    elif op == '&':
        for i in range(len(a)):
            a[i] &= b[i]
    elif op == '^':
        for i in range(len(a)):
            a[i] ^= b[i]

if __name__ == '__main__':
    import argparse, sys
    ap = argparse.ArgumentParser(description='Performs a bitwise operation on multiple files and outputs the result')
    ap.add_argument('files', metavar='FILE', type=argparse.FileType('rb', 0), nargs='+',
                    help='filenames of files to use as operands')

    group = ap.add_mutually_exclusive_group(required=True)
    group.add_argument('-a', '--and', dest='op', action='store_const', const='&',
                       help='use bitwise AND operation (0101 & 0011 = 0001)')
    group.add_argument('-o', '--or', dest='op', action='store_const', const='|',
                       help='use bitwise OR operation (0101 & 0011 = 0111)')
    group.add_argument('-x', '--xor', dest='op', action='store_const', const='^',
                       help='use bitwise XOR operation (0101 & 0011 = 0110)')

    args = ap.parse_args()
    data = bytearray(0)
    for f in args.files:
        filedata = bytearray(f.read())
        f.close()
        bit_op(args.op, data, filedata)

    sys.stdout.buffer.write(data)

