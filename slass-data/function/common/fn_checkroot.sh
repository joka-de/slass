#
# SLASS - fn_checkroot
#
# Author: joka
#
# Description:
# check if the user running the script has the root privilegue
#
# Parameter(s):
# None <Any>
#
# Return Value:
# None <Any>
#
fn_checkroot () {
	fn_getFunctionStatus $FUNCNAME

	if [[ $EUID -ne 0 ]]; then
		fn_printMessage "You are not root. Aborting." "" "error"
		exit 1
	fi
}