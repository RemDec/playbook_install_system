#! /bin/bash

if [ "$1" == "dry" ]; then
  ansible-playbook site.yml -i inventory -u root -k --check
else
  ansible-playbook site.yml -i inventory -u root -k
fi
