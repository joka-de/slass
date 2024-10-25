#
# SLASS - fn_installsteamcmd
# 
# Author: joka
# 
# Description:
# installs steamcmd to folder $basepath
# 
# Parameter(s):
# None <Any>
# 
# Return Value:
# None <Any>
#
fn_installsteamcmd () {
	fn_debugMessage "$FUNCNAME: start" ""
	
	# read usernames
	fn_readuser $basepath/config/server.scfg
	
	rm -rf $basepath/steamcmd
	mkdir $basepath/steamcmd --mode=775
	fn_debugMessage "$FUNCNAME: cleared steamdir" ""
	#
	cd ${basepath}/steamcmd
	wget -nv http://media.steampowered.com/installer/steamcmd_linux.tar.gz
	tar -xvzf steamcmd_linux.tar.gz
	${basepath}/steamcmd/steamcmd.sh +runscript ${basepath}/slass-data/rsc/update.steam
	fn_printMessage "SteamCMD was installed and is up to date!" ""
	#
	# set file permissions of ~/Steam folder
	find -L /home/${useradm}/Steam -type d -exec chmod 775 {} \;
	find -L /home/${useradm}/Steam -type f -exec chmod 664 {} \;
	fn_debugMessage "$FUNCNAME: end" ""
}