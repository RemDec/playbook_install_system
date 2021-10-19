# playbook_install_system
Ansible Playbook to install all commonly used packages, system configurations and facilties on a Debian-like distro, also replacing the WM by an i3 setup.

It is split in several roles that can also be launched indivdually passing Ansible tags :
- system_setup : create a user and under his /home a predefined file system hierarchy to work on
- packages :
- cli_facilities :
- i3 :
- repositories :
