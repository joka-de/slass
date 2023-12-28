#
# SLASS - fn_rmserverdir
# 
# Author: joka
# 
# Description:
# remove the directory of a server instance a3srv{i}
# 
# Parameter(s):
#1. server directory <string>
#
# Return Value:
# None <Any>
#
fn_rmserverdir () {
	#
	if (( $# != 1 )); then
		fn_debugMessage "$FUNCNAME: aborted, one argument needed" ""
		return 1
	fi
	#
	if [ -d "${1}" ]; then
		rm -rf "${1}"
		fn_debugMessage "$FUNCNAME: Directory ${1} removed" ""
	else
		fn_debugMessage "$FUNCNAME: Directory ${1} to remove not found" ""
	fi
	return 0
}
