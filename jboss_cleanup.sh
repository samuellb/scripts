#!/bin/sh

# This script cleans up temporary files from JBoss 7 / EAP 6. Put it in your JBoss root directory and run it from there.
# It is normal for it to show some error messages due to already deleted files (e.g. if ran several times in a row).

rm -r standalone/deployments/ejbca.ear* standalone/data/timer-service-data/* standalone/data/wsdl/ejbca.ear/ standalone/tmp/vfs/* standalone/tmp/work/jboss.web/default-host/*

