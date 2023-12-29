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
	sudo -u $useradm rm -rf $basepath/steamcmd
	sudo -u $useradm mkdir $basepath/steamcmd --mode=775
	fn_debugMessage "$FUNCNAME: cleared steamdir" ""
	#
	sudo apt install lib32gcc-s1 lib32stdc++6 rename
	cd ${basepath}/steamcmd
	sudo -u $useradm wget -nv http://media.steampowered.com/installer/steamcmd_linux.tar.gz
	sudo -u $useradm tar -xvzf steamcmd_linux.tar.gz
	sudo -iu $useradm ${basepath}/steamcmd/steamcmd.sh +runscript ${basepath}/slass-data/rsc/update.steam
	fn_printMessage "SteamCMD was installed and is up to date!" ""
	# set file permissions of ~/Steam folder
	sudo -u $useradm find -L /home/${useradm}/Steam -type d -exec chmod 775 {} \;
	sudo -u $useradm find -L /home/${useradm}/Steam -type f -exec chmod 664 {} \;
	fn_debugMessage "$FUNCNAME: end" ""
}