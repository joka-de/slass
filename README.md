<p align="center">
    <img src="https://github.com/joka-de/slass/doc/logo.png" width="480">
</p>

<p align="center">
    <sup><strong>short: slass</br>
	Tested on Ubuntu 16.04 (Xenial)</br>
    Visit us on <a href="ts3server://ts3.seelenlos.eu?port=9987">Teamspeak 3</a> | <a href="http://arma.seelenlos.eu">seelenlos.eu</a> | <a href="https://units.arma3.com/unit/seelenlos">seelenlos on Steam</a></br>
	(c)2017 by seelenlos</strong></sup></p>

*License:* GNU GPLv3


## General
This is not a one-click-get-a-server script. Read this manual BEFORE you begin. Really.

## What it does
The seelenlos Arma 3 Server Script
- installs three arma3 server instances on Linux
- saves precious storage by using symlinks (about the space for one installation is needed)
- implements the instances as services in the OS
- restarts the servers if they crash
- provides diagnostic commands on the running servers
- installs Arma3 mods from the workshop
- provides a central config file where you can specify an individual mod set for each server
- differentiates between mod, servermod, and clientmod
- manages the *.bikey files in dependency of the loaded mods for each server instance
- provides a central mission repository for all instances
- creates meaningful servernames for the server browser depending on the loaded mods
- reconfigures the servers upon each restart according to the config files
- can be used to update Arma3 and the mods by a single command
- provides a simple way to have an almighty admin and a maintance user, who can update/install mods, and add missions, but not fumble around in the important scripts
