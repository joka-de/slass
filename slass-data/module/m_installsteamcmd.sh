#
# SLASS - m_install
# 
# Author: joka
# 
# Description:
# installer module for steam and arma3
# 
# Parameter(s):
# 1. option { start | stop | restart | status | log } <string>
# 2. server id {i} <integer>
# 
# Return Value:
# None <Any>
#
# load slass.scfg
fn_readuser $basepath/config/server.scfg

goinst="n"
fn_printMessage "
---------------------------------------------
This will install the seelenlos arma3 server script
including steamcmd

into: $basepath
for admin-user: $useradm
a3server will be executed by: $userlnch
both being in group: $grpserver

Modify $basepath/config/slass.scfg to change the above.

The script will OVERWRITE existing folders in the installation directory,
and you will be asked for the 'sudo' password by the script.

Do you want to continue? (y/n)" ""

read goinst
if [ $goinst != "y" ]; then
	exit 0
fi
#
## scripted user management - OMITTED FOR NOW
#fn_printMessage "
#Do you want the users named above to be created?
#! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
#WARNING, if they already exist, they will be DELETED, including their home folders!
#! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
#
#Create Users? (y/n)"
#read mkuser
#if [ $mkuser == "y" ]; then
#	fn_deleteAndCreateUser
#fi
#
# install steamcmd
fn_installsteamcmd