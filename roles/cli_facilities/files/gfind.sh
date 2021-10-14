#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage :"
    echo "   $0 pattern : do a recursive case-insensitive EXTENDED grep on pattern from current directory"
    exit 1
fi

grep -Ri -E "$1" *
