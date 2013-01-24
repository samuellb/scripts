#!/bin/sh

# Found in many places on the Internet, the real author is unknown...
# http://stackoverflow.com/questions/955976/ever-need-to-parse-the-svn-log-for-files-committed-by-a-particular-user-since-a
# http://stackoverflow.com/questions/14071404/using-awk-to-svn-log-to-get-a-list-of-file-committed-by-a-specific-user

username=`id -un`

svn log -v -r{2012-08-01}:HEAD 
| awk '/^r[0-9]+ / {user=$3} /./ {if (user=="'$username'") {print}}'
| grep -E "^   M|^   G|^   A|^   D|^   C|^   U" 
| awk '{print $2}'
| sort | uniq

