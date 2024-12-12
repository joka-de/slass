#
# SLASS - fn_readuserSteam
# 
# Author: joka
# 
# Description:
# read "usersteam steampassword" from file scfg
# 
# Parameter(s):
# None <Any>
#
# Return Value:
# None <Any>
#
fn_readuserSteam () {
	fn_getFunctionStatus $FUNCNAME

	fn_printMessage "$FUNCNAME: start" "" "debug"
	
	usersteam=$(fn_getJSONData "" "global.slass.usersteam" "-r")
	steampassword=$(fn_getJSONData "" "global.slass.steampassword" "-r")
	
	fn_printMessage "$FUNCNAME: stop" "" "debug"
}