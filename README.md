<p align="center">
    <img src="https://github.com/joka-de/slass/raw/master/doc/logo.png" width="640">
</p>

<p align="center">
    <sup><strong>short: slass</br>
	Tested on Ubuntu 20.04 (Focal)</br>
    Visit us on TS3: <a href="ts3server://45.130.104.195?port=9987">Seelenlos TS3</a> | <a href="https://units.arma3.com/unit/seelenlos">seelenlos on Steam</a></br>
	(c)2017 by seelenlos</strong></sup></p>

*License:* GNU GPLv3

## General
seelenlos Arma3 Server Script (SLASS) will greatly ease the installation and management of multiple Arma3 servers including mods from the Steam workshop.</br>

## The Master-Branch is WIP, use the stable-branch

## Install
Open a shell.
Create User for the server
adduser username --gecos "" --disabled-password
For Security, leave the password disabled, so only root can log in.

Switch to the user
sudo su - username

Install the Server
./slass/slass install-steamcmd
./slass/slass install-arma3