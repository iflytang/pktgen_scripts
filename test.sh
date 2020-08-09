#!/bin/bash

# author: tsf
# date: 2020-08-06

# test
trap 'echo "123" ; signal_handler; exit' SIGINT

function signal_handler() {
    ## stop to send packet
    echo "the shell script will be stopped, and pktgen stops running ..."
}

STOP_POINTS=3
for ((i=0;i<200;i++))
do
    echo $i
    sleep 1s
    #sleep 1s
    if (($i>=$STOP_POINTS))
    then
        let STOP_POINTS++
        echo "stop to send after ${STOP_POINTS} points."
        break
    fi
done


