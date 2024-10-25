#
# SLASS - fn_readuser
# 
# Author: joka
# 
# Description:
# read "usersteam steampassword" from file scfg
# 
# Parameter(s):
# 1. path to file
#
# Return Value:
# None <Any>
#
fn_readuserSteam () {
	fn_debugMessage "$FUNCNAME: start"
	source <(sed '/^usersteam/!d' $1)
	source <(sed '/^steampassword/!d' $1)
	
	fn_debugMessage "$FUNCNAME: stop"
}