#! /bin/bash

if [ "$1" == "dry" ]; then
  ansible-playbook site.yml -i inventory --check
fi
