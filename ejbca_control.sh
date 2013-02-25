#!/bin/sh -e
#
#  ejbca_control -- Script to re-deploy/re-install EJBCA and restart JBoss
#
#  Copyright (c) 2013 Samuel Lidén Borell <samuel@kodafritt.se>
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

usage() {
    cat >&2 <<EOF
usage: $0 COMMAND

Common commands:
    
    fresh  = jbossdown, dbwipe, p12wipe, jbossfullclean, deploy,
             jbossup, waitup, install, jbossrestart
    codechange  = jbossdown, jbosstempclean, deploy, jbossup, waitup

Other commands:

    dbclean
    deploy
    jbossfullclean
    jbosstempclean
    jbossdown
    jbossrestart = jbossdown, jbosstempclean, jbossup
    jbossup
    p12wipe
    waitshutdown
    waitup
    
 *** Note that "fresh", "dbwipe" and "p12wipe" are destructive! ***
 This tool is not able to parse connection strings and will always
 connect to localhost as root and wipe the specified db.

EOF
}

if [ $# = 0 -o "x$1" = 'x--help' ]; then
    usage
    exit
fi

starttime=`date +%s`


# Set/Check EJBCA_HOME
EJBCA_HOME=${EJBCA_HOME:-$PWD}
if [ ! -e "$EJBCA_HOME/bin/ejbca.sh" ]; then
    echo "EJBCA_HOME not set correctly?"
    exit 1
fi

# Determine JBOSS_HOME
if [ ! -e "$EJBCA_HOME/conf/ejbca.properties" ]; then
    echo "Missing conf/ejbca.properties"
    exit 1
fi

getprop() {
    propfile="$1"
    prop="`echo $2 | sed 's/\./\\./g'`"
    grep "^$prop=" "$EJBCA_HOME/conf/$propfile" | sed "s/^$prop=//"
}

#JBOSS_HOME=`grep '^appserver\.home=' "$EJBCA_HOME/conf/ejbca.properties" | sed 's/^appserver\.home=//'`
JBOSS_HOME=`getprop ejbca.properties appserver.home`

if [ ! -d "$JBOSS_HOME/server/default" ]; then
    echo "appserver.home not set correctly?"
    exit 1
fi



dbwipe() {
    echo "=== dbwipe"
    cd "$JBOSS_HOME"
    dbtype=`getprop database.properties database.name`
    user=`getprop database.properties database.username`
    pass=`getprop database.properties database.password`
    url=`getprop database.properties database.url`
    db=`echo "$url" | sed -r 's/[a-z]+:\/\/[^\/]*\/([^?]*).*/\1/g' | sed 's/jdbc://g'`
    #printf "dbtype=%s\nuser=%s\npass=%s\ndb=%s\n" "$dbtype" "$user" "$pass" "$db"
    
    dbtype=${dbtype:-hsqldb}
    
    case "$dbtype" in
        mysql)
            # localhost is assumed!
            #cat <<EOF
            mysql -u root <<EOF
drop database if exists $db;
create database $db;
grant all on $db.* to $user@localhost identified by '$pass';
EOF
            return;;
        hsqldb)
            rm -rf server/default/data/*
            return;;
        *)
            echo "Database type not implemented: $dbtype"
            exit 1;;
    esac
}

fresh() {
    jbossdown
    dbwipe
    p12wipe
    jbossfullclean
    deploy
    jbossup
    waitup
    install
    jbossrestart
}

codechange() {
    jbossdown
    jbosstempclean
    deploy
    jbossup
    waitup
}

deploy() {
    echo "=== deploy"
    cd "$EJBCA_HOME"
    ant -q deploy
}

install() {
    echo "=== install"
    cd "$EJBCA_HOME"
    yes '' | ant -q install
}

jbossfullclean() {
    echo "=== jbossfullclean"
    cd "$JBOSS_HOME"
    rm -rf server/default/deploy/ejbca* server/default/data/* server/default/conf/mobilera
}

jbosstempclean() {
    echo "=== jbosstempclean"
    cd "$JBOSS_HOME"
    rm -rf server/default/work/* server/default/tmp/*
}

jbossdown() {
    echo "=== jbossdown"
    cd "$JBOSS_HOME"
    findjboss > /dev/null && bin/shutdown.sh -S
    waitshutdown
}

jbossrestart() {
    jbossdown
    jbosstempclean
    jbossup
}

jbossup() {
    echo "=== jbossup"
    cd "$JBOSS_HOME"
    nohup bin/run.sh > /dev/null 2> /dev/null &
}

findjboss() {
    for pid in `pidof java`; do
        if grep -qE "org\.jboss\.Main$" /proc/$pid/cmdline; then
            echo $pid
            return 0
        fi
    done
    return 1
}

p12wipe() {
    echo "=== p12clean"
    cd "$EJBCA_HOME"
    rm -f p12/*
}

waitshutdown() {
    echo "=== waitshutdown"
    cd "$JBOSS_HOME"
    
    timer=10
    printf "Stopping jboss...    "
    while [ $timer -gt 0 ]; do
        findjboss > /dev/null || break
        tail server/default/log/server.log | grep -Fq '(JBoss Shutdown Hook) Shutdown complete' && break
        sleep 1
        timer=$((timer-1))
        printf "\b\b\b%3d" $timer
    done
    echo
}

waitup() {
    echo "=== waitup"
    cd "$JBOSS_HOME"
    
    timer=70
    printf "Starting jboss...    "
    while [ $timer -gt 0 ]; do
        tail server/default/log/server.log | grep -Eq 'JBoss \(Microcontainer\) .* Started in ' && { echo; return 0; }
        sleep 1
        timer=$((timer-1))
        printf "\b\b\b%3d" $timer
    done
    
    echo
    tail -f server/default/log/server.log
    return 1
}

killjboss() {
    echo "=== killjboss"
    for pid in `pidof java`; do
        if grep -qE "org\.jboss\.Main$" /proc/$pid/cmdline; then
            kill $pid
            sleep 5
            kill -9 $pid
        fi
    done
}



# Run specified command
while [ -n "$1" ]; do
    $1
    shift
done

endtime=`date +%s`
printf "=== Total time taken: %d s\n" $((endtime - starttime))


