#!/bin/sh

# do not rename to "supsend" which is a shell built-in

lxlock
sleep 1
sudo sh -c 'echo mem > /sys/power/state'

