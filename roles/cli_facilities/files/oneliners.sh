#!/bin/bash

cat <<<'EOF'

# -- System
# spy output of another bash process
sudo strace -p{pid} -e trace=write


EOF
