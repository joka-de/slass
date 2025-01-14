#
# SLASS - fn_stopall
#
# Author: joka
#
# Description:
# execute stop command for all server instances
#
# Parameter(s):
#1. server directory <string>
#
# Return Value:
# None <Any>
#
fn_stopall () {
	fn_getFunctionStatus $FUNCNAME

	# detect existing server instance directories and iterate over them
	ls ${1}/a3/ | sed 's/a3//g' | sed 's/[^0-9]//g' | sed '/^[[:space:]]*$/d' | while read id; do
		fn_printMessage "found server directory a3srv${id}, stopping Server $id now..." ""
		source ${1}/slass-data/module/m_a3server.sh stop $id
	done

	return 0
}
