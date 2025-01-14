#
# SLASS - fn_getFunctionStatus
#
# Author: PhilipJFry
#
# Description:
# Print status of function in debug mode (is it used and/or deprecated)
#
# Parameter(s):
# 1: Functionname <String>
#
# Return Value:
# None <Any>
#
fn_getFunctionStatus () {
	if [[ -z "$1" ]]; then
		printf "$(tput setaf 2)[SLASS]$(tput sgr0)$(tput setaf 1)[Error]:$(tput sgr0) $FUNCNAME: Functionname missing!\n"
		return 1
	fi

	local status="[Active]"

	if [[ -f "$basepath//slass-data/function/deprecated/$1.sh" ]]; then
		status="[Deprecated]"

		if [[ "$debug" == "y" ]]; then
			printf "$(tput setaf 2)[SLASS]$(tput sgr0)$(tput setaf 5)[Debug]:$(tput sgr0) $1 Used | Status: $(tput setaf 3)$status$(tput sgr0)\n"
		fi
	fi
}