#! /bin/bash

# either target a file either await something on stdin, copy input in clipboard
if [ "$1" ]; then
    xclip -sel clip "$1"
else
    xclip -sel clip
fi
