#!/bin/sh

setalternative() {
    if update-alternatives --quiet --list "$1" > /dev/null 2>&1; then
        update-alternatives --quiet --set "$1" "$location/$2"
    fi
}

setcommonalternatives() {
    setalternative appletviewer bin/appletviewer
    setalternative appletviewer.1.gz man/man1/appletviewer.1.gz
    setalternative extcheck bin/extcheck
    setalternative extcheck.1.gz man/man1/extcheck.1.gz
    setalternative idlj bin/idlj
    setalternative idlj.1.gz man/man1/idlj.1.gz
    setalternative itweb-settings jre/bin/itweb-settings
    setalternative itweb-settings.1.gz jre/man/man1/itweb-settings.1.gz
    setalternative jarsigner bin/jarsigner
    setalternative jarsigner.1.gz man/man1/jarsigner.1.gz
    setalternative java jre/bin/java
    setalternative java.1.gz jre/man/man1/java.1.gz
    setalternative javac bin/javac
    setalternative javac.1.gz man/man1/javac.1.gz
    setalternative javadoc bin/javadoc
    setalternative javadoc.1.gz man/man1/javadoc.1.gz
    setalternative javah bin/javah
    setalternative javah.1.gz man/man1/javah.1.gz
    setalternative javap bin/javap
    setalternative javap.1.gz man/man1/javap.1.gz
    setalternative javaws jre/bin/javaws
    setalternative javaws.1.gz jre/man/man1/javaws.1.gz
    setalternative jconsole bin/jconsole
    setalternative jconsole.1.gz man/man1/jconsole.1.gz
    setalternative jdb bin/jdb
    setalternative jdb.1.gz man/man1/jdb.1.gz
    setalternative jexec jre/lib/jexec
    setalternative jexec-binfmt jre/lib/jar.binfmt
    setalternative jhat bin/jhat
    setalternative jhat.1.gz man/man1/jhat.1.gz
    setalternative jinfo bin/jinfo
    setalternative jinfo.1.gz man/man1/jinfo.1.gz
    setalternative jmap bin/jmap
    setalternative jmap.1.gz man/man1/jmap.1.gz
    setalternative jps bin/jps
    setalternative jps.1.gz man/man1/jps.1.gz
    setalternative jrunscript bin/jrunscript
    setalternative jrunscript.1.gz man/man1/jrunscript.1.gz
    setalternative jsadebugd bin/jsadebugd
    setalternative jsadebugd.1.gz man/man1/jsadebugd.1.gz
    setalternative jstack bin/jstack
    setalternative jstack.1.gz man/man1/jstack.1.gz
    setalternative jstat bin/jstat
    setalternative jstat.1.gz man/man1/jstat.1.gz
    setalternative jstatd bin/jstatd
    setalternative jstatd.1.gz man/man1/jstatd.1.gz
    setalternative keytool jre/bin/keytool
    setalternative keytool.1.gz jre/man/man1/keytool.1.gz
    setalternative orbd jre/bin/orbd
    setalternative orbd.1.gz jre/man/man1/orbd.1.gz
    setalternative pack200 jre/bin/pack200
    setalternative pack200.1.gz jre/man/man1/pack200.1.gz
    setalternative policytool jre/bin/policytool
    setalternative policytool.1.gz jre/man/man1/policytool.1.gz
    setalternative rmic bin/rmic
    setalternative rmic.1.gz man/man1/rmic.1.gz
    setalternative rmid jre/bin/rmid
    setalternative rmid.1.gz jre/man/man1/rmid.1.gz
    setalternative rmiregistry jre/bin/rmiregistry
    setalternative rmiregistry.1.gz jre/man/man1/rmiregistry.1.gz
    setalternative schemagen bin/schemagen
    setalternative schemagen.1.gz man/man1/schemagen.1.gz
    setalternative serialver bin/serialver
    setalternative serialver.1.gz man/man1/serialver.1.gz
    setalternative servertool jre/bin/servertool
    setalternative servertool.1.gz jre/man/man1/servertool.1.gz
    setalternative tnameserv jre/bin/tnameserv
    setalternative tnameserv.1.gz jre/man/man1/tnameserv.1.gz
    setalternative unpack200 jre/bin/unpack200
    setalternative unpack200.1.gz jre/man/man1/unpack200.1.gz
    setalternative wsgen bin/wsgen
    setalternative wsgen.1.gz man/man1/wsgen.1.gz
    setalternative wsimport bin/wsimport
    setalternative wsimport.1.gz man/man1/wsimport.1.gz
    setalternative xjc bin/xjc
    setalternative xjc.1.gz man/man1/xjc.1.gz
}

case "$1" in
    openjdk6)
        export location="/usr/lib/jvm/java-6-openjdk-amd64"
        setcommonalternatives
        ;;
    openjdk7)
        export location="/usr/lib/jvm/java-7-openjdk-amd64"
        setcommonalternatives
        ;;
    *)
        echo "usage: $0  VERSION" >&2
        echo "" >&2
        echo "Where VERSION can be either openjdk6 or openjdk7" >&2
        ;;
esac


