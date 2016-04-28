#!/bin/sh -e

if [ $# = 1 -a -r "$1" -a ! -w "$1" ]; then
    echo "WARNING!!! File is not writeable: $1"
    read REPLY
fi
nano "$@"
