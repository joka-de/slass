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
	fn_getFunctionStatus $FUNCNAME
	
	if (( $# != 1 )); then
		fn_printMessage "$FUNCNAME: aborted, one argument needed" "" "error"
		return 1
	fi
	
	if [ -d "${1}" ]; then
		rm -rf "${1}"
		fn_printMessage "Directory ${1} removed" ""
	else
		fn_printMessage "Directory ${1} to remove not found" "" "warning"
	fi
	return 0
}
