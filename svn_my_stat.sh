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
# Example: svn_my_stat.sh 1000:HEAD jdoe

svn_changed() {
    svn blame --revision $1:$2 -- $4 | grep -E "^ [0-9]* *${3} "
}

svn diff --revision $1:$2 --summarize | \
cut -c9- | \
while read path; do
    if [ -n "$(svn_changed $1 $2 $3 $path)" ]; then
        echo "$3 changed $path"
    else
        echo "Someone else changed $path"
    fi
done

