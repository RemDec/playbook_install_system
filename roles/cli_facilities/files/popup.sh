#!/bin/bash


let timesec=60*${1:-15};
while true; do
    sleep $timesec;
    i3-msg "exec i3-nagbar -m \"Time to look around !\"" > /dev/null;
done
