#
# SLASS - fn_mka3masterdir
# 
# Author: joka
# 
# Description:
# builds the folder $basepath/a3master
# 
# Parameter(s):
# None <Any>
# 
# Return Value:
# None <Any>
#
fn_mka3masterdir () {
	
	# set permissions on basepath
	sudo chown ${useradm}:${grpserver} $basepath
	sudo -u $useradm chmod 775 $basepath
	fn_debugMessage "$FUNCNAME: permissions set on $basepath" ""
	#
	# (re)build a3master
	local list=("")
	if [ $debug != "y"  ]; then
		list=("a3/a3master" "steamcmd")
	fi
	#
	for folder in "${list[@]}"; do
		if [ -d "${basepath}/${folder}" ]; then
			sudo -u $useradm rm -rf $basepath/$folder
		fi
		sudo -u $useradm mkdir $basepath/$folder --mode=775
	done
	#
	#debug lines to clear a3master, but not downloaded content
	if [ $debug == "y"  ]; then
		sudo -u $useradm rm -rf ${basepath}/a3/a3master/_mods
		sudo -u $useradm rm -rf ${basepath}/a3/a3master/cfg
		#sudo -u $useradm rm -rf ${basepath}/a3/a3master/log
		sudo -u $useradm rm -rf ${basepath}/a3/a3master/userconfig/
	fi
	#
	#sudo -u $useradm mkdir ${basepath}/scripts/service --mode=754
	sudo -u $useradm mkdir ${basepath}/a3/a3master/_mods --mode=775
	sudo -u $useradm mkdir ${basepath}/a3/a3master/cfg --mode=775
	#sudo -u $useradm mkdir ${basepath}/a3/a3master/log --mode=775
	#sudo -u $useradm mkdir ${basepath}/scripts/logs --mode=775
	#sudo -u $useradm mkdir ${basepath}/scripts/tmp --mode=775
	sudo -u $useradm mkdir ${basepath}/a3/a3master/userconfig/ --mode=775
	#
	fn_debugMessage "$FUNCNAME: subfolders in ${basepath}/a3/ created" ""
	#
	# copy files
	#sudo -u $useradm cp ${basepath}/installer/rsc/servervars.cfg ${basepath}/scripts/service/
	#sudo -u $useradm chmod 644 ${basepath}/scripts/service/servervars.cfg
	#sudo -u $useradm cp ${basepath}/installer/rsc/modlist.inp ${basepath}/scripts/
	#sudo -u $useradm chmod 664 ${basepath}/scripts/modlist.inp
	#sudo -u $useradm cp ${basepath}/installer/rsc/a3srvi.sh ${basepath}/scripts/service/
	#sudo -u $useradm chmod 754 ${basepath}/scripts/service/a3srvi.sh
	#sudo -u $useradm cp ${basepath}/installer/rsc/prepserv.sh ${basepath}/scripts/service/
	#sudo -u $useradm chmod 754 ${basepath}/scripts/service/prepserv.sh
	#sudo -u $useradm cp ${basepath}/installer/rsc/a3common.cfg ${basepath}/a3master/cfg/
	#sudo -u $useradm chmod 664 ${basepath}/a3master/cfg/a3common.cfg
	#sudo -u $useradm cp ${basepath}/installer/rsc/basic.cfg ${basepath}/a3master/cfg/
	#sudo -u $useradm chmod 664 ${basepath}/a3master/cfg/basic.cfg
	#for index in $(seq 3); do
	#	sudo -u $useradm cp  ${basepath}/installer/rsc/a3indi.cfg ${basepath}/a3master/cfg/a3indi${index}.cfg
	#	sudo -u $useradm chmod 664 ${basepath}/a3master/cfg/a3indi${index}.cfg
	#done
	
	# (re)build Arma3Profile
	if [ -d "/home/"${userlnch}'/.local/share/Arma 3 - Other Profiles/'"${grpserver}" ]; then
		sudo -u $userlnch rm -rf /home/${userlnch}"/.local/share/Arma 3 - Other Profiles/"${grpserver}
	fi
	sudo chmod 755 /home/${userlnch}
	sudo -u $userlnch mkdir -p /home/${userlnch}"/.local/share/Arma 3 - Other Profiles/"${grpserver} --mode=775
	sudo -u $userlnch cp ${basepath}/installer/rsc/profile.Arma3Profile /home/${userlnch}"/.local/share/Arma 3 - Other Profiles/"${grpserver}/${grpserver}.Arma3Profile
	sudo -u $userlnch chmod 464 /home/${userlnch}'/.local/share/Arma 3 - Other Profiles/'${grpserver}/*.Arma3Profile
	fn_debugMessage "$FUNCNAME: profile file copied" ""
}