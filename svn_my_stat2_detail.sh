#!/bin/sh

# Found in many places on the Internet, the real author is unknown...
# http://stackoverflow.com/questions/955976/ever-need-to-parse-the-svn-log-for-files-committed-by-a-particular-user-since-a
# http://stackoverflow.com/questions/14071404/using-awk-to-svn-log-to-get-a-list-of-file-committed-by-a-specific-user

if [ -z "$1" ]; then
    echo "usage: $0 startrev"
    echo
    echo "example: $0 2012-08-01"
    exit
fi

username=`id -un`
startrev=$1

svn log -v -r'{'$startrev'}':HEAD | awk '/^r[0-9]+ / {user=$3} /./ {if (user=="'$username'") {print}}'

