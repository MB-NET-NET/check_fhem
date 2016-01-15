#!/bin/sh

DEV=/dev/ttyACM0
PORT=2323

while (true)
do
    	if [ -e $DEV ];
	then
	    	logger "CUL relay started. $DEV via $PORT"
		/usr/bin/socat -ly GOPEN:$DEV,raw,echo=0 TCP-LISTEN:$PORT
		logger "socat exited.  Sleeping..."
	else
	    	logger "$DEV not found.  Waiting for device to appear..."
	fi
	sleep 10
done
