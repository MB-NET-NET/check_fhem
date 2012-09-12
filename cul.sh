#!/bin/sh

DEV=/dev/ttyACM0

while (true)
do
	/usr/bin/socat -ly GOPEN:$DEV,raw,echo=0 TCP-LISTEN:2323
	sleep 1
done
