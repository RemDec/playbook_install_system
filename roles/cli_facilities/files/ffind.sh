#!/bin/bash

if [ -z "$1" ];then
    echo "Usage:"
    echo "  $0 filename 'expression' : invoke 'find' command, case unsensitive and accepting any pre/suffix to the name, with expression as a string standing for the rest of command (to apply -ls or whatever)"
    exit 1
fi

find -iname "*$1*" $2
