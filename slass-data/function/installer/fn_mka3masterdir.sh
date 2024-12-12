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
	fn_getFunctionStatus $FUNCNAME
	fn_printMessage "$FUNCNAME: start" "" "debug"	
	
	# read usernames
	fn_readuser $basepath/config/server.scfg
	
	# set permissions on basepath
	chmod 775 ${basepath}
	chmod 775 ${basepath}/slass
	chmod 775 ${basepath}/slass-data/p_a3server.sh
	fn_printMessage "$FUNCNAME: permissions set on $basepath" "" "debug"
	
	rm -rf ${basepath}/a3/a3master
	mkdir ${basepath}/a3/a3master --mode=775
	
	mkdir ${basepath}/a3/a3master/_mods --mode=775
	mkdir ${basepath}/a3/a3master/cfg --mode=775
	mkdir ${basepath}/a3/a3master/userconfig/ --mode=775
	
	fn_printMessage "$FUNCNAME: subfolders in ${basepath}/a3/ created" "" "debug"
	
	# (re)build Arma3Profile
	if [[ -d "/home/"${userlnch}'/.local/share/Arma 3 - Other Profiles/'"${grpserver}" ]]; then
		rm -rf /home/${userlnch}"/.local/share/Arma 3 - Other Profiles/"${grpserver}
	fi

	chmod 755 /home/${userlnch}
	mkdir -p /home/${userlnch}"/.local/share/Arma 3 - Other Profiles/"${grpserver} --mode=775
	cp ${basepath}/slass-data/rsc/profile.Arma3Profile /home/${userlnch}"/.local/share/Arma 3/"${grpserver}.Arma3Profile
	chmod 464 /home/${userlnch}'/.local/share/Arma 3 - Other Profiles/'${grpserver}/*.Arma3Profile
	fn_printMessage "$FUNCNAME: profile file copied" "" "debug"
	fn_printMessage "$FUNCNAME: end" "" "debug"
}