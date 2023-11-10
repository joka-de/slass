<p align="center">
    <img src="https://github.com/joka-de/slass/raw/master/doc/logo.png" width="640">
</p>

<p align="center">
    <sup><strong>short: slass</br>
	Tested on Ubuntu 20.04 (Focal)</br>
    Visit us on TS3: <a href="https://invite.teamspeak.com/5.189.150.110/">Seelenlos TS3</a> | <a href="https://units.arma3.com/unit/seelenlos">seelenlos on Steam</a></br>
	(c)2017 by seelenlos</strong></sup></p>

*License:* GNU GPLv3

## General
This script will greatly ease the installation and management of three Arma3 servers including mods from the Steam workshop.</br></br>This is not a one-click-get-a-server script. Its usage is simple, but do yourself a favor and read this manual BEFORE you begin. Really. Basic knowledge of the linux command line usage is assumed.

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

## How it works
**Basic Structure**
The script will generate a master installation (a3master), that will never be started. Using symlinks, it will build three server instances out of this master installation. The instances are later run as a system service (SysVInit). The whole set of server files, including the mission repository (mpmissions folder) and *.Arma3Profile is being shared among the instances, but the instances use individual config files. A script will manage the mods and their keys to load for each server instance.
Individually for each instance you can set:
- (part of) the config file
- the mods to use including their keys
- the servername</br>

All instances will share</br>

- the Arma3-files and mod files (update all instances at once)
- the *.Arma3Profile
- basic config settings
- a common logfile folder

**What happens on installation** </br>
You begin by putting the script folder **installer** into an arbitrary folder on your system. Upon start, the script will then establish an Arma3 installation inside that arbitrary folder. Depending on you installation path, it will build individual config and script files for your server, install steamcmd, set the required file ownerships and rights, and install the servers as a system service. The installation finishes with an update of Arma3 and the mods.
Refer to the file **doc/folder_struc.png** for a general overview where to find the files and what they do.

**What happens on update** </br>
File ownership in a3master will be reset to avoid issues from remote upload of mission files etc. The server instances are then stopped, and an update (or install, if not already there) of Arma3 and the mods is performed. After the update, the file rights in a3master are reset, all mods are renamed to lower case (avoids issues with crashing mods on linux) and the folders of the instances are cleared and rebuild. Finally, the severs are booted back up.

**What happens on start/restart** </br>
On start, all config files are newly read in to consider possible config edits. The config file **modlist.inp** defines the mods to load, individually for each instance. Depending on that config, the server name and the startup options (-mods= ) are build. Then the script will generate the config file for the respective instance, and copy the individually needed set of **.bikey - files** into its **keys** folder. Logfiles older than {deldays} **(servervars.cfg)** will be deleted, a new logfile will be written. Afterwards, the instance will boot, being monitored by a watchdog process. The watchdog reboots the server if it crashes. The watchdog is also active if the server stopped externally, i.e. you can issue the #shutdown command ingame to read an updated server config.
## Installation

**1. Prerequisites**
- ensure you have the root password for your machine at hand
- create an arbitrary folder for the servers, we suggest **/srv/arma3/**
- copy the script folder "installer" in that folder, e.g. **/srv/arma3/installer**
- open the file install.cfg inside the folder "installer", change the user informations therein to your wishes. The users can be created by the script, or manually before you start the installation; refer to the commands in **./installer/adddelusr.sh** on how to do so. They will have the following functions</br>
**useradmin** - Is owner of the files in the server folder, can add/delete/modify files and manage servers. You can use your normal user account with sudo privileges for this. Make sure he is in **grpserver** (see below).</br>
**userlnch** - Is the owner of the server process once fired up. For security reasons, he should not be able to get a shell nor become root.</br></br>	*Use strong Passwords for both users anyway, never hand them out! A server with web access is not a toy!*</br></br>**grpserver** - a user group in which both preceding noted users must be, preferably as initial-group. Add additional users to that group, to allow them to make basic maintenance of the gameserver (update, mod/mission install, restart, cfg changes)
- prepare the server config files in **./installer/rsc**</br>
**a3common.cfg** - master config file containing settings common for all server instances.</br>
**a3inidi.cfg** - template config file containing individual settings for each server instance. After installation, three individual copies of this file will exist, edit them if needed.</br>
**basic.cfg** - loaded as -cfg file by the server process</br>
**servervars.cfg** - config file setting additional options for the server executable, normally you don't need to edit this</br>
- determine the mods to install, to do so edit **./installer/rsc/modlist.inp** . The file has seven columns:</br>
	I. shortname of the mod</br>
	II. steam-app-id of the mod; if the mod is not in the workshop, insert the word **local**</br>
 	III. mod type; use</br>
		**mod** if the mod is to be loaded by server and client (key and mod is loaded), e.g. ACE</br>
		**cmod** if the mod is only to be loaded client side (only key is loaded on server), e.g. JSRS</br>
		**smod** if the mod is only to be loaded by the server (only mod is loaded on server), e.g. ace_server</br>
	IV. to VI. contains a binary key 0/1 selecting if the mod is to be loaded on server #1/#2/#3</br>
	VII. is the name of the mod included in the servername for the server browser; Type "xx" if do not want the mod to appear in the server name for the server browser; see also the example file in **./installer/optrsc/** </br></br>**prepserv.sh** - defines the server names, among other stuff. Edit the entry **hostname_base="Generic Arma3"** and the entrys **" hostname id1=' Server 1 |' "** to **" hostname id3=' Server 3 |' "** to your wishes. The final server name will be composed as</br>
**Hostname_base+hostname_idx+Modlist**, e.g. **"Generic Arma3 Server 1 | SLT, ACE"**</br>Edit more of the file to break it ...
- Make sure that you have the steam login of a user with arma3 and the mods being stated in "modlist.inp" subscribed at hand.

**3. Start Installation**
- ensure the file **./installer/a3install.sh** is executable for your current user (chown , chmod 744)
- run **./installer/a3install.sh** , confirm continuation request
- decide, if you want the users to be created, see above
- the script may ask you to install some packages named like lib32..., those are needed by steamcmd
- consider saving or immediately applying the commands printed on the prompt (visudo, ln) in another console; refer to the *Usage-Update* section below
- confirm the begin of the download, or choose to download later by issuing the update script (see below).
- The login into steam may fail on the first try, because you are probably logging in from a machine unknown to steam. In this case the script will freeze at the line "Verifiying Login-Data...". Abort the script by pressing **Ctrl-C** in that case. Then start **/srv/arma3/steamcmd/steamcmd.sh** and enter the guard code received per mail. Refer to the steamcmd manual on HowTo, or see below. Afterwards restart the update process by issuing **sudo /srv/arma3/scripts/runupdate.sh**. **runupdate.sh** from now on will always be the file to start in order to **update arma3 or install a mod**.
- when you see **app_update 233780 validate** arma3 is being downloaded, be patient
- when prompted, you may copy missions and non-workshop mods into the **./a3master** folder
- note the output on screen. If the installation of mods **...workshop_download_item ...** fails with timeout, this is becaus you download a large mod for the first time and the download takes too long. The issue is a bug in steamcmd. The script will attempt to download it again multiple times. The download attempts are cumulative, so each time you run the update, you make progress.

**4. Done**</br>
Put at least one mission into mpmissions and Enjoy Arma3! You may delete the **installer** folder now.

## Usage
**1. Manage Servers**</br>
The servers are implemented into your system as system services. You **manage** them by issuing the command</br>
**sudo service a3srvX OPTION**</br>
Replace X with the number of the server and OPTION with</br>
**start** - you guess it</br>
**stop** - ahem...well</br>
**restart** - Does a restart. If you have many big mods loaded, this command may fail because the server takes to long to stop. Just issue **stop** and after a short wait **start** again.</br>
**status** - prints the service status</br>
**log** - prints the serverlog onto the prompt in realtime as it is written, abort with Ctrl-C</br>
**Update** - the servers and mods by running **sudo /srv/arma3/scripts/runupdate.sh**. The script will then download/update A3 and the workshop-mods registered in **modlist.inp**.</br>
**Update Mods only** - by running **sudo /srv/arma3/scripts/runwsupdate.sh**. The script will then download/update the workshop-mods registered in **modlist.inp**.</br>
</br>
You may want to add the line</br>
*%{grpserver}      ALL=NOPASSWD: /usr/sbin/service a3srv[1-3] *, {a3instdir}/scripts/runupdate.sh**</br>
to the sudoers file with visudo to avoid the system asking for the password. This is a must if you want to enable other members of the group that do not have root permissions (i.e. the maintance users) to issue the commands. Replcace {grpserver} with your groupname and {a3instdir} with your installation path.</br>
You will also need to execute the command</br>
*ln -s /home/{useradmin}/Steam /home/{userupdate}/Steam*</br>
for each user you want to enable to run the update script. Run the command as the user {userupdate}. Replace {useradmin} and {userupdate} with the respective user names. The command will create a symlink of the Steam cache folder into the home directory of {userupdate}. This forces steam to use only one repository of cache files for all users, preventing several issues.

**2. Install mods**</br>
For **workshop** mods: Ensure you have the mod subscribed for the user you wish to use for the update. Write an entry for the mod to install into modlist.inp as described in the installation section. Run an update.</br></br>
For **non-workshop** (i.e. local) mods: Put the mod into **/srv/arma3/a3master/_mods/** and copy the **.bikey** file (if one is needed) in a respective folder **./_mods/@modname/keys**. Set the file owner and permissions like the other mods have it. You may alternatively run an update to let the script set the permissions. Write an entry for the mod to install into **modlist.inp** as described in the installation section. Reboot the respective server to load the mod. </br></br>
In both cases, ensure the **.bikey** file (if one is needed) is in a folder **./_mods/@modname/keys**, if you observe problems loading the mod. Otherwise the script won't find it.

**3. Edit server configs**</br>
Thats simple: Edit what you need to, and restart the corresponding server.

## Appendix
**I. Enter Steam Guard code**
- run **/srv/arma3/steamcmd/steamcmd.sh**; make sure you run this command as {useradmin} or a {userupdate} for whom the *ln* command has already been applied
- enter **login USERNAME**
- enter the guard code
- enter **exit**
