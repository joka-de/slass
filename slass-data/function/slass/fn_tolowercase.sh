#
# SLASS - modlowercase
#
# Author: joka
#
# Description:
# makes all mod files lowercase
#
# Parameter(s):
# 1. Path <String>
#
# Return Value:
# None <Any>
#
fn_tolowercase () {
	fn_getFunctionStatus $FUNCNAME
	fn_printMessage "  ... renaming $1 to lowercase" ""
	find -L ${1} -depth -execdir rename -f 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
	fn_printMessage " - DONE" ""
}