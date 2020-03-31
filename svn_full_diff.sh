#!/bin/bash
# Update this for the username and releases you want to check

if [ -z "$1" ]; then
    echo "usage:  $0  SVN-URL  USERNAME  REVISION" >&2
    exit 1
fi

URL=$1
USERID=$2
LAST_RELEASE_REVISION=$3

# Loop over all changes.. you probably want to pipe this to a .diff file
echo "Doing diff for user $USERID from revision $LAST_RELEASE_REVISION"
REVISIONS=$(svn log "$URL" --username "$USERID" -r "$LAST_RELEASE_REVISION":HEAD | grep "$USERID" | awk '{print $1}' | sed 's/r//g')
printf %s "$REVISIONS" | while IFS= read -r REVISION
do
        echo "Diff: $REVISION:$((REVISION-1))"
        svn log "$URL" --username "$USERID" -r "$REVISION"
        svn diff "$URL" --username "$USERID" -r $((REVISION-1)):"$REVISION"
done

