#!/bin/bash
/etc/runit/2&
RUNSVDIR_PID=$! # assign the PID of first command i.e. /etc/runit/2& to this variable
echo "Started runsvidr, PID is $RUNSVDIR_PID"
trap "echo Container has been stopped && /etc/runit/3 && kill -HUP $RUNSVDIR_PID && wait $RUNSVDIR_PID" SIGTERM SIGHUP
wait $RUNSVDIR_PID # it will wait for the PID command to finish i.e. /etc/runit/2&