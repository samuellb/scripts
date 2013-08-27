#!/bin/bash
#
# Made by l0b0:
# http://stackoverflow.com/questions/341310/list-all-files-changed-by-a-particular-user-in-subversion
# https://github.com/l0b0/tilde
#
# @param $1: Start revision
# @param $2: End revision
# @param $3: User
#
# Example: svn_my_stat.sh 1000 HEAD jdoe

if [ -z "$1" ]; then
    echo "usage: $0  startrev  [endrev]  [username]" >&2
    echo "" >&2
    echo "example: $0 2012-10-01 HEAD" >&2
    echo "example: $0 2012-10-01 HEAD johndoe" >&2
    exit 1
fi

startrev='{'$1'}'
endrev=${2:-HEAD}
user=${3:-`whoami`}

if [ "x$endrev" != "xHEAD" ]; then
    endrev='{'$endrev'}'
fi

svn_changed() {
    svn blame --revision $1:$2 -- $4 | grep -E "^ [0-9]* *${3} "
}

svn diff --revision $startrev:$endrev --summarize | \
cut -c9- | \
while read path; do
    if [ -n "$(svn_changed {$1} $endrev $user $path)" ]; then
        echo "$user changed $path"
    else
        echo "Someone else changed $path"
    fi
done

