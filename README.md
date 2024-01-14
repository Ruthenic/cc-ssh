# cc-ssh
simplistic shell protocol for remotely accessing CraftOS computers
## installation
run `wget run https://raw.githubusercontent.com/Ruthenic/cc-ssh/install.lua` to install `ssh` and `sshd` to `/bin`, as well as a default sshd config named `sshd.json` to `/`.  
alternatively, install from pinestore.
## usage
after installing (and adding to path) on the server, run `sshd sshd.json` to run sshd with the default config; make sure a modem is connected to your computer.  
afterwards, install (and add to path) on the client and run `ssh server` to connect to the server (unless you changed the hostname, in which case you should change `server` to whatever the hostname is)
## todo
- implement asymmetric cryptography to avoid snooping as best as possible
- add client timeout when sshd dies for some reason
- improve performance
## issues
- `edit` does not work properly with large files, and generally makes the connection die. (however, alternative text editors such as [zed](https://github.com/TheZipCreator/zed-cc/) seemingly work fine)