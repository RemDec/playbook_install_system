# playbook_install_system
Ansible Playbook to install all commonly used packages, system configurations and facilties on a Debian-like distro, also replacing the WM by an i3 setup.

It is split in several roles that can also be launched indivdually passing Ansible tags :
- system_setup : 
  - create a regular user/group
  - build under his /home a predefined file system hierarchy to work on
- packages :
  - using the system's package manager, remove undesired packages
  - install a pool of new packages depending the type of installation (minimal/common/security)
  - set up customized config files for installed packages
- cli_facilities :
  - user aliases and useful snippets
  - shell behaviour
- i3 :
  - TODO
- repositories :
  - TODO 

Launch it using 

```
./launch_playbook.sh [dry] [other parameters to pass to ansible_playbook]
```
