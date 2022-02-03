#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage :"
    echo "   $0 pattern [more_grep_opts] : do a recursive case-insensitive EXTENDED grep on pattern from current directory"
    exit 1
fi

grep -RIin$2 -E "$1" * | awk -F: '{print $1, $2"|"$3}'
