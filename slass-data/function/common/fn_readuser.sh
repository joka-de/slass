#
# SLASS - fn_readuser
# 
# Author: joka
# 
# Description:
# read "useradm userlnch grpserver" from file scfg
# 
# Parameter(s):
# 1. path to file
#
# Return Value:
# None <Any>
#
fn_readuser () {
	fn_debugMessage "$FUNCNAME: start"
	source <(sed '/^useradm/!d' $1)
	source <(sed '/^userlnch/!d' $1)
	source <(sed '/^grpserver/!d' $1)
	fn_debugMessage "$FUNCNAME: stop"
}