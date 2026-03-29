#!/usr/bin/env sh
set -x
cd /root
apk update
apk add gcc linux-headers alpine-sdk findutils
apk fetch -R bash newt dialog
gcc -static -o /rebootp.bin /rebootp.c

