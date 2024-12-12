#
# SLASS - fn_readuser
# 
# Author: joka
# 
# Description:
# read "useradm userlnch grpserver" from file scfg
# UPDATE username is fixed to the logged in user
# 
# Parameter(s):
# 1. path to file
#
# Return Value:
# None <Any>
#
fn_readuser () {
	fn_getFunctionStatus $FUNCNAME
	
	fn_printMessage "$FUNCNAME: start" "" "debug"
		
	useradm=$(whoami)
	userlnch=$useradm
	grpserver=$useradm

	fn_printMessage "$FUNCNAME: userlnch $userlnch" "" "debug"
	fn_printMessage "$FUNCNAME: useradm $useradm" "" "debug"
	fn_printMessage "$FUNCNAME: grpserver $grpserver" "" "debug"

	fn_printMessage "$FUNCNAME: stop" "" "debug"
}
