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
**Version 2.0** Now with Headless Clients and hierarchical JSON config.

## Features
slass (seelenlos Arma 3 Server Script)
#### install / update
- installs multiple arma3 server instances on Linux
- saves precious storage by using symlinks (about the space for one installation is needed, even if you run four or more servers)
- provides a central mission repository for all instances
- installs Arma3 mods from the workshop
#### headless clients (HC)
- automated setup of HeadlessClients (HC) to each Server Instance. Number of HC per instance can be set from 0...dafuck
- HC are autostarted / rebooted / stopped with the main instance
- HC configuration is automated to fit the master process
#### mod, mission and mependencies managemant
 - mods and mission will be only downloaded if there is an update
 - if a mod/mission has dependencies the script will automatically download these mods
 - if a mod/mission has dependencies the script will automatically load the mods if you start a server
#### config
- provides a central config file for all server instances and mods where you can specify an individual mod set for each server
- differentiates between mod, servermod, and clientmod
- supports CDLC
- manages the *.bikey files in dependency of the loaded mods for each server instance
- creates meaningful servernames for the server browser depending on the loaded mods
#### management
- updates Arma3 and all mods by a single command
- ready for automated server updates / restarts
- restarts the servers if they crash
- provides diagnostics on the running servers
- reconfigures the servers upon each restart according to the config files
- logs all events at a central location

## slass 2.0 release
Version 2 is a major rework of the older versions of slass, with much of the code rewritten. Biggest improvement is the support for Headless Clients. Other major improvements are the ability to run automated updates and the use of a centralized config. Code has been cleaned up and a more meaningful folder and code structure has been established.

## How it works - Basic Concept
The script will generate a master installation (./a3/a3master), that will never be started. Using symlinks, it will build each server instances out of this master installation. The whole set of server files, including the mission repository (mpmissions folder) and *.Arma3Profile is being shared among the instances, but the instances use individual configs and startup commands. Slass will manage the mods and their keys to load for each server instance. The servers will only need about the disc space of one server, because each instance only exists in symlinks. You can run as many instances at once as far as your RAM allows. We tested to up to four simultaneously running server instances, i.e. servers.
For each server instance you can set individually:
- config file
- mods to use including their keys
- servername</br>

All instances will share</br>
- the Arma3-files and mod files (update all instances at once)
- the *.Arma3Profile
- config settings; you can set which ones
- logfile folder

See [Documentation Folder](https://github.com/joka-de/slass/tree/master/doc "Documentation Folder") for more details.

## Using slass

#### Commands
slass [option 1] [option 2]

[option 1]
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

[option 2] - valid only if option 1 = (start | stop | restart | log | status)
- {i}
  - id number of your server instance, like 1 or 2
</br>

#### Install
1. Open a shell.

2. Install prerequisites
```sh
sudo apt install lib32gcc-s1 lib32stdc++6 rename jq
```

3. Create User for the server. For Security, leave the password disabled. You can still login to this user using ssh with a keypair or from root using su.
```sh
adduser a3server --gecos "" --disabled-password
```

4. Switch to the user
```sh
sudo su - a3server
```

6. Install the Server

Download the files from this repository to the users home. We assume the folder to be
`~/slass`

Steamcmd
```sh
./slass/slass install-steamcmd
```
Arma3
```sh
./slass/slass install-arma3
```

If prompted
```sh
This computer has not been authenticated for your account using Steam Guard.
Please check your email for the message from Steam, and enter the Steam Guard
 code from that message.
You can also enter this code at any time using 'set_steam_guard_code'
 at the console.
```
enter the steam guard code by issuing
```sh
./slass/steamcmd/steamcmd.sh
```
and then `login  <yoursteamuser>`, follow instuctions, then restart installation by
```sh
./slass/slass install-arma3
```

#### Configuration

The configs are located in `./config`

##### server.json
- main config file in[ json](https://en.wikipedia.org/wiki/JSON " json") format
- sets parameters for slass and for the servers

###### Structure
- global
  - slass
  - key : value
- server 1
  - slass
  - key : value
  - ( ... )
- server 2
   - ( repeat )
- server ( i )

###### Usage:
- Set key-value pairs and objects in the object "global" AND/OR in the object "server". If a key is defined in both global and server, the server entry will be used. You can understand the global section as a default setting.
- Set parameters in the object slass to define options of the script. These are used by slass only and not passed to arma.
- The key "_comment" can be used for commenting. You can add more of these lines. Do not use any other comment format.
- Every other content will be written to the server config on startup of the server. slass will parse the json and reformat the entries to Arma3-Standard.
- Add an object with an arbitrary server number i <integer> to the config to define more servers. Start the server with the command `slass start i`. Server i must exist in the config in order to be started.

*Important:* Check validity of your config with a [JSON-Parser](http://json.parser.online.fr/ "JSON-Parser"). See [example file](https://github.com/joka-de/slass/blob/master/config/server.json "example file") for formatting of Arma3-Config Entries in the JSON.

###### slass parameters
- "debug" : "y"</br>enable debug mode on the prompt
- "otherparams" : "-filepatching"</br>other startup variables to be sent to the server
- "ip" : "1.2.3.4"</br>ip of the NIC to be used
- "hostname" : "servername"</br>server name in the browser
- "headlessClient" : 3</br> number of HeadlessClients
- "port" : 2302</br>Port Number, the server will use more ports, kepp 10 ports clear between the instances
- "logfilelifetime" : 3</br>Age of the oldest logfile. Older ones are deleted during update/restart.
- "usersteam" : "username"</br>Steam user for Arma3-Updates.
- "steampassword" : "password"</br>Password of the user.

##### Mods
There are two objects you have to define in the server.json file

  1. "modrepo" : {}</br>must be defined in .global.slass</br>It is your mod repository from which you can choose mods for the individual server
  2. "modtoload" : []</br>must/can defined in .global.slass or/and .server{i}.slass</br>If you define *modtolaod* in the .global.slass all mods in the array wil be loaded on all server</br>If define *modtoload* in .global.slass and .server{i}.slass, both mod sets will be merged

##### Structure
"modrepo" : {}
```
{
    "modrepo" : {
        "modname" : {
            "appid" : <workshop-id> or "local",
            "apptype" : "mod" or "cmod" or "smod",
            "inservername" : "name-of-mod-in-server-name"
        },

        "othermodname" : {
            "appid" : <workshop-id> or "local",
            "apptype" : "mod" or "cmod" or "smod",
            "inservername" : "name-of-mod-in-server-name"
        }
    }
}
```

  In the modrepo object you have to define every mod as an object with 3 key values

- *"modname" : {}*
    - **shortname**</br>of the mod for your convenience</br>slass will label the mod folder in your arma3 directory by this, e.g. cup_w for CUP Weapons
    - keep the name short, lowercase and don't use whitespaces, linux dosn't like that and the size of the startup parameter "mod" is limited
- *"appid" : number/string*
    - **workshop-id**</br>of the mod,</br>insert the word **local** if the mod is not in the workshop, i.e. loaded from disc like creator dlc</br>

- *"apptype" : string*
    - **mod** if the mod is to be loaded by server and client (key and mod is loaded), e.g. ACE</br>
    - **cmod** if the mod is only to be loaded client side (only key is loaded on server), e.g. JSRS</br>
    - **smod** if the mod is only to be loaded by the server (only mod is loaded on server), e.g. ace_server</br>

- *"inservername" : string*
    - name of the mod included in the server name for the server browser e.g. "CBA_A3" or "Spearhead 1944"
    - delete or set this key to empty string if you do not want the mod to appear in the server name for the server browser

"modtoload" : []
```json
{
    "global" : {
        "slass" : {
            "modtoload" : [
                "modname1",
                "modname2"
            ]
        }
    },

    "server{i}" : {
        "slass" : {
            "modtoload" : [
                "modname4",
                "modname10"
            ]
        }
    }
}
```
- *"modtoload" : []*</br> 
    - is a array of strings</br>
    - add the **modname** from the **modrepo** to load mods when the server starts

Example:

```json
{
  "global" : {
    "slass" : {
      "modrepo" : {
        "cba" : {
          "_comment" : "CBA_A3",
          "appid" : 1234123123,
          "apptype" : "mod",
          "inservername" : "CBA_A3"
        },

        "ace" : {
          "_comment" : "ace3",
          "appid" : 5646545646,
          "apptype" : "mod",
          "inservername" : ""
        },

        "cup_w" : {
          "_comment" : "CUP Weapons",
          "appid" : 8498304889,
          "apptype" : "mod"
        }
      },

      "modtoload" : [
        "cba"
      ]
    }
  },

  "server1" : {
    "slass" : {
      "modtoload" : [
        "ace"
      ]
    }
  },

  "server2" : {
    "slass" : {
      "modtoload" : [
        "ace",
        "cup_w"
      ]
    }
  }
}
```

The "_comment" key will be not interpreted, you can use this key to have store more information about the mission. All server load cba because it is defined in the global section. "CBA_A3" is merged with the server name. Server1 starts with cba and ace while server2 starts with cba, ace and cup_w. After you do the workshop update with "./slass.sh workshop-update" three other keys will be added to the mod.

- *"require" : {}*
    - all mods that are necessary to use the mod
- *"lastupdate" : number*
    - unix times tamp

Example:

After you do the workshop update

```json
{
  "global" : {
    "slass" : {
      "modrepo" : {
        "cba" : {
          "_comment" : "CBA_A3",
          "appid" : 1234123123,
          "apptype" : "mod",
          "inservername" : "CBA_A3",
          "lastupdate": 1743590962
        },

        "ace" : {
          "_comment" : "ace3",
          "appid" : 5646545646,
          "apptype" : "mod",
          "inservername" : "",
          "lastupdate": 1743591092,
          "require": {
            "450814997": "cba"
          }
        },

        "cup_w" : {
          "_comment" : "CUP Weapons",
          "appid" : 8498304889,
          "apptype" : "mod",
          "lastupdate": 1738255675,
          "require": {
            "450814997": "cba"
          }
        }
      },

      "modtoload" : [
        "cba"
      ]
    }
  },

  "server1" : {
    "slass" : {
      "modtoload" : [
        "ace"
      ]
    }
  },

  "server2" : {
    "slass" : {
      "modtoload" : [
        "ace",
        "cup_w"
      ]
    }
  }
}
```
The mod "cba" don't have dependencies so the key "require" is not added. "cup_w" and "ace" need "cba" to run properly and the script add this mod to "cup_w" and "ace". If you start a server and forget to add "cba" to "modtoload", it is automatically loaded.

##### Missions
You have to define one object in the server.json file

1. "missionrepo" : {}
  </br> - must be defined in .global.slass</br> - it is your mission repository to keep track of required mods for each mission</br> - works only for mission you can download from workshop (scenarios)</br> - missions like antistasi.altis which are included in the antistasi mod are not supported

##### Structure
"missionrepo" : {}
```
{
    "missionsrepo" : {
        "missionname" : {
            "appid" : <workshop-id>
        },

        "othermissionname" : {
            "appid" : <workshop-id>
        }
    }
}
```
In the missionrepo object you have to define every mission as an object with 1 key value

- *"missionname" : {}*
    - **shortname**</br>
      of the mission for your convenience</br>
      don't use whitespaces and special characters
- *"appid" : number*
    - **workshop-id**</br>of the mission

Example:

```json
{
  "global" : {
    "slass" : {
      "missionrepo" : {
        "desertocean" : {
          "_comment" : "Desert Ocean [SP/COOP 1-8]"
          "appid" : 3386249759
        },

        "slterroristhunt" : {
          "_comment" : "SL[SP_CO-06]TerroristHunt"
          "appid" : 5646545646
        }
      }
    }
  }
}
```

The "_comment" key will be not interpreted, you can use this key to have store more information about the mission. After you do the workshop update with "./slass.sh workshop-update" three other keys will be added to the mission and it copy the file to "./a3master/mpmissions"

- *"require" : {}*
    - all mods that are necessary to use the mission
- *"lastupdate" : number*
    - unix times tamp

- *"filename" : string*
    - filename of the mission
    - the script will remove all special characters and set it to lowercase to prevent errors 

Example:

After you do the workshop update

```json
{
  "global" : {
    "slass" : {
      "missionrepo" : {
        "desertocean" : {
          "_comment" : "Desert Ocean [SP/COOP 1-8]"
          "appid" : 3386249759,
          "lastupdate": 1745755027,
          "filename": "desertocean[spcoop1-8].sefrouramal.pbo"
        },
                
        "slterroristhunt" : {
          "_comment" : "SL[SP_CO-06]TerroristHunt"
          "appid" : 5646545646,
          "require": {
            "583496184": "cup_terraincore",
            "583544987": "cup_terrain",
            "843425103": "rhsafrf"
          },
          "lastupdate": 1746458234,
          "filename": "sl[sp_co-06]terroristhunt.chernarus.pbo"
        }
      }
    }
  }
}
```
The mission "desertocean" has no dependencies so the key "require" is not added. The mission slterroristhunt require three mods (CUP Terrain, CUP Terrain Core, RHSAFRF). If you start a server with the mission slterroristhunt, the script will automatically load the required mods if you have forget to put it in the "modtoload" array.

#####   basic.cfg
loaded by the server process as -cfg file (NOT -config)</br>

#### Logging
Issue the command `./slass/slass log 1` to tail the log of server 1 to the prompt.</br></br>Logfiles are stored in `~/log`. Each Server and each of its HC will have a log.</br></br>Update-Logs of A3 and the Workshop are kept there as well.

#### Uninstall

1. Open a shell.
2. Remove the user and its home

```
deluser --remove-home a3server
```
#### Automated Updates
The basic idea is to run the command `./slass update` regularly. You can do this by (ana)cron or other mechanics.

##### Example with cron
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

Consider adding slass to your bashrc to ease usage.
