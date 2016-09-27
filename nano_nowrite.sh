#!/bin/sh -e

msg() {
    printf '\033[1;31m%s\033[0m\n' "$1"
}

if [ $# = 1 ]; then
    # Check if it's an existing file
    if [ -r "$1" ]; then
        if [ ! -w "$1" ]; then
            msg "WARNING!!! File is not writeable: $1"
            read REPLY
        fi
    else
        # It's a new file, check if the containing directory is writable
        dir="$(dirname "$1")"
        if [ ! -w "$dir" ]; then
            msg "WARNING!!! Can't write in directory: $dir"
            read REPLY
        fi
    fi
fi
nano "$@"
