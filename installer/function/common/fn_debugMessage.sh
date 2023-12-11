#
# SLASS - fn_debugMessage
# 
# Author: PhilipJFry
# 
# Description:
# Print a debug message in red if debug mode is on
# 
# Parameter(s):
# Message <String>
# 
# Return Value:
# None <Any>
#

fn_debugMessage () {
	if [[ $# != 0 && $debug == "y" ]]; then
			case $# in
				1)
					fn_printMessage "$1" "" "$RED"
				;;
				2)
					fn_printMessage "$1" "$2" "$RED"
				;;
				3)
					fn_printMessage "$1" "$2" "$RED"
				;;
			esac
	fi
}
