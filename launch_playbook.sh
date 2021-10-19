#! /bin/bash

if [ "$1" == "dry" ]; then
  ansible-playbook site.yml -i inventory -u root -k --check ${@: 2}
else
  ansible-playbook site.yml -i inventory -u root -k ${@: 1}
fi
