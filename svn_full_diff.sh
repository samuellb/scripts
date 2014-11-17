#!/bin/bash
# Update this for the username and releases you want to check

if [ -z "$1" ]; then
    echo "usage:  $0  REVISION" >&2
    exit 1
fi

USERID="samuellb"
LAST_RELEASE_REVISION="$1"
#LAST_RELEASE_REVISION="15021"
#URL="https://svn.cesecore.eu/svn/ejbca/branches/primekey/Branch_5_0/ejbca"
URL="https://svn.cesecore.eu/svn/ejbca/trunk"
#URL="https://svn.cesecore.eu/svn/ejbca/branches/Branch_4_0/ejbca"
#echo "Enter SVN password: " 1>&2
#stty -echo
#read PASSWORD
#stty echo
# Loop over all changes.. you probably want to pipe this to a .diff file
echo "Doing diff for user $USERID from revision $LAST_RELEASE_REVISION"
REVISIONS=`svn log $URL --username $USERID -r $LAST_RELEASE_REVISION:HEAD | grep $USERID | awk '{print $1}' | sed 's/r//g'`
printf %s "$REVISIONS" | while IFS= read -r REVISION
do
        echo "Diff: $REVISION:$((REVISION-1))"
        svn log $URL --username $USERID -r $REVISION
        svn diff $URL --username $USERID -r $((REVISION-1)):$REVISION
done

