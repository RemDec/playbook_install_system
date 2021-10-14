#! /bin/bash

# write clipboard content either on a file either on stdout
if [ "$1" ]; then
    xclip -o -sel clip > "$1"
else
    xclip -o -sel
fi
