#!/bin/sh
exec 2>&1

PATH=/command:/sbin:/bin:/usr/sbin:/usr/bin

LAST=0
test -x /etc/runit/reboot && LAST=6

echo 'Waiting for services to stop...'
sv -w196 force-stop /etc/service/*
sv exit /etc/service/*

echo 'Shutdown...'
/etc/init.d/rc $LAST