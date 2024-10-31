<p align="center">
    <img src="https://github.com/joka-de/slass/raw/master/doc/logo.png" width="640">
</p>

<p align="center">
    <sup><strong>short: slass</br>
	Tested on Ubuntu 20.04 (Focal)</br>
    Visit us on TS3: <a href="ts3server://45.130.104.195?port=9987">Seelenlos TS3</a> | <a href="https://units.arma3.com/unit/seelenlos">seelenlos on Steam</a></br>
	(c)2017 by seelenlos</strong></sup></p>

*License:* GNU GPLv3

## The Master-Branch is WIP, use the stable-branch

## General
seelenlos Arma3 Server Script (SLASS) will greatly ease the installation and management of multiple Arma3 servers including mods from the Steam workshop.</br>

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
