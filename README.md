# playbook_install_system
Ansible Playbook to install all commonly used packages, system configurations and facilties on a Debian-like distro, also replacing the WM by an i3 setup.

There are 3 possible levels of installation :
1. `minimal` : all prerequisites packages
2. `common` : utilitary tools for a desktop installation setup like browser, editors, ...
3. `security` : auxiliary tools useful for pentesting purposes

It can be tuned for each installation, like other parameters, by editing [group_vars/all.yml](group_vars/all.yml).

The play is split in several roles that can also be launched individually passing Ansible `tags` :
- **system_setup**   `[system]` : 
  - create a regular user/group `[user-mgmt]` 
  - build under his /home a predefined file system hierarchy to work on
- **packages** `[pkgs]` :
  - using the system's package manager, remove undesired packages
  - install a pool of new packages depending the type of installation (`minimal`/`common`/`security`)
  - set up customized config files for installed packages
- **cli_facilities** `[cli]` :
  - user aliases and useful snippets
  - shell interface/behaviour
- **i3** `[i3]` :
  - install lightdm and i3 + customized config depending the Desktop Environment
  - set it as defaults system-wide
- **repositories** `[repos]` :
  - TODO 

Launch it using

```bash
./launch_playbook.sh [dry] "[other parameters to pass to ansible_playbook]"
```

### TODO
- packages : hypervisor level, config file only if package installed
- cli_facilities : fonts, snippets (show c/c, ...)
- i3 : config depending DE
- launch_script : support running on localhost, show possible tags, overriding inventory, ...
- use keys instead of password
