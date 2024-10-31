<p align="center">
    <img src="https://github.com/joka-de/slass/raw/master/doc/logo.png" width="640">
</p>

<p align="center">
    <sup><strong>short: slass</br>
	Tested on Ubuntu 22.04 (Jammy JellyFish)</br>
    Visit us on TS3: <a href="ts3server://45.130.104.195?port=9987">Seelenlos TS3</a> | <a href="https://units.arma3.com/unit/seelenlos">seelenlos on Steam</a></br>
	(c)2017 by seelenlos</strong></sup></p>

*License:* GNU GPLv3

## General
seelenlos Arma3 Server Script (SLASS) will greatly ease the installation and management of multiple Arma3 servers including mods from the Steam workshop.</br>
**Version 2.0** Now with Headless Clients

## Features
slass (seelenlos Arma 3 Server Script)
- installs multiple arma3 server instances on Linux
- installs Arma3 mods from the workshop
- provides diagnostic commands on the running servers
- provides HeadlessClients (HC) to each Server Instance. Number of HC per instance can be set from 0...?
- HC are autostarted / rebooted / stopped with the main instance
- HC configuration is automated to fit the master process
- provides a central config file for all server instances
- provides a central config file where you can specify an individual mod set for each server
- differentiates between mod, servermod, and clientmod
- manages the *.bikey files in dependency of the loaded mods for each server instance
- updates Arma3 and all mods by a single command
- allows auotmated server updates / restarts
- restarts the servers if they crash
- saves precious storage by using symlinks (about the space for one installation is needed, even if you run four or more servers)
- provides a central mission repository for all instances
- creates meaningful servernames for the server browser depending on the loaded mods
- reconfigures the servers upon each restart according to the config files
- logs all events at a central location

**Release of slass 2.0**</br>
Version 2 is a major rework of the older versions of slass, with much of the code rewritten. Most important improvement is the support for Headless Clients. Other major improvements are the ability to run automated updates and the use of a centralized config. Code has been cleaned up and a more meaningful folder and code structure has been established.

**How it works - Basic Structure**</br>
The script will generate a master installation (./a3/a3master), that will never be started. Using symlinks, it will build each server instances out of this master installation. The whole set of server files, including the mission repository (mpmissions folder) and *.Arma3Profile is being shared among the instances, but the instances use individual config files and startup commands. A script will manage the mods and their keys to load for each server instance. The servers will only need about the disc space of one server, because each instance only exists in symlinks. You can run as many instances at once as far as your RAM allows. We tested to up to four simultaneously running server instances, i.e. servers.
For each server instance you can set individually.
- (part of) the config file
- the mods to use including their keys
- the servername</br>

All instances will share</br>
- the Arma3-files and mod files (update all instances at once)
- the *.Arma3Profile
- basic config settings
- a common logfile folder

## Using slass

**Commands**</br>
</br>
slass [option 1] [opt2]

Option 1
- install-steamcmd
  - installs steamcmd
- install-arma3
  - installs arma3 unsing steamcmd, existing installations are cleared
- update-game
  - updates arma3 using steamcmd
- update-ws
  - updates the mods using steamcmd
- stopall
  - stops all running server instances
- update
  - updates arma3 and the mods using steamcmd
- start
  - starts a server
- stop
  - stops a server
- restart
  - you guess it
- log
  - prints the log of a server
- status
  - prints the status of the server instance and its HC
		
Option 2 - only with Option 1 = (start | stop | restart | log | status)
- {i}
  - id number of your server instance, like 1 or 2
</br>

**Configuration**</br>

The configs are located in `./config`

- **server.scfg** - main config file</br>
  - sets variables for all insances and each individual instance
    You must define each instance you want to start here.
    (description to be extended)
- **a3master.cfg** - master config template with game settings for all server instances
  - sets parameters not defined in server.scfg
- **modlist.inp** - Mods to load / install</br>
  The file has several columns:</br>
  1. shortname of the mod for your convenience</br>
  2. name of the mod included in the servername for the server browser; Type "xx" if do not want the mod to appear in the server name for the server browser </br>
  3. steam-app-id of the mod; if the mod is not in the workshop, insert the word **local**</br>
  4. mod type; use</br>
    - **mod** if the mod is to be loaded by server and client (key and mod is loaded), e.g. ACE</br>
    - **cmod** if the mod is only to be loaded client side (only key is loaded on server), e.g. JSRS</br>
    - **smod** if the mod is only to be loaded by the server (only mod is loaded on server), e.g. ace_server</br>
  5. and following contains a binary key 0/1 selecting if the mod is to be loaded on server #1/#2/#3/ ...</br>
- **basic.cfg** - loaded as -cfg file by the server process</br>

## Install
1. Open a shell.

2. Install prerequisites
```
sudo apt install lib32gcc-s1 lib32stdc++6 rename
```

3. Create User for the server. For Security, leave the password disabled. You can still login to this user using ssh with a keypair or from root using su.
```
adduser a3server --gecos "" --disabled-password
```

4. Switch to the user
```
sudo su - a3server
```

6. Install the Server

Download the files from this repository to the users home. We assume the folder to be `~/slass`

Steamcmd
```
./slass/slass install-steamcmd
```
Arma3
```
./slass/slass install-arma3
```

If prompted
```
This computer has not been authenticated for your account using Steam Guard.
Please check your email for the message from Steam, and enter the Steam Guard
 code from that message.
You can also enter this code at any time using 'set_steam_guard_code'
 at the console.
```
enter the steam guard code by issuing
```
./slass/steamcmd/steamcmd.sh
```
and then `login  steamuser`, follow instuctions, then restart installation by
```
./slass/slass install-arma3
```

## Uninstall
1. Open a shell.
2. Remove the user and its home
   ```
   deluser --remove-home a3server
   ```

## Automated Updates
The basic idea is to run the command `./slass update` regularly. You can do this by (ana)cron or other mechanics.

### Example with cron
1. Open a shell and make a script file, i.e. `touch ./updatea3.sh`
2. Edit the file to something like that:
```
#!/bin/bash
#
# script file for automated update and startup of a3 servers
cd /home/a3server/slass/
./slass update

sleep 5

./slass start 2
sleep 15
./slass start 3
```
3. make it executable
4. add the file to cron `crontab -e`
```
00 09 * * * /home/a3server/slass/updatea3.sh
```
