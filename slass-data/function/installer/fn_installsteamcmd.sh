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
	fn_getFunctionStatus $FUNCNAME
	fn_printMessage "$FUNCNAME: start" "" "debug"

	# read usernames
	fn_readuser

	rm -rf $basepath/steamcmd
	mkdir $basepath/steamcmd --mode=775
	fn_printMessage "$FUNCNAME: cleared steamdir" "" "debug"

	cd ${basepath}/steamcmd
	wget -nv http://media.steampowered.com/installer/steamcmd_linux.tar.gz
	tar -xvzf steamcmd_linux.tar.gz
	${basepath}/steamcmd/steamcmd.sh +runscript ${basepath}/slass-data/rsc/update.steam
	fn_printMessage "SteamCMD was installed and is up to date!" ""

	# set file permissions of ~/Steam folder
	find -L /home/${useradm}/Steam -type d -exec chmod 775 {} \;
	find -L /home/${useradm}/Steam -type f -exec chmod 664 {} \;
	fn_printMessage "$FUNCNAME: end" "" "debug"
}