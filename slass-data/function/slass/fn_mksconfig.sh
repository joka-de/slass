#
# SLASS - fn_mksconfig
# 
# Author: Fry
# 
# Description:
# create scfg for server instance a3srv{i}
# 
# Parameter(s):
# 1. server id {i} <integer>
#
# Return Value:
# scfgi path <String>
#
fn_mksconfig () {
	fn_getFunctionStatus $FUNCNAME
	
	local scfgi=""

	if [[ -z "$1" ]]; then
		fn_printMessage "$FUNCNAME: servernumber not provided!" "" "error"
		exit 1
	fi

	scfgi="${basepath}/a3/a3master/cfg/a3srv${1}.scfg"

	if [[ -f $scfgi ]]; then
		rm $scfgi
	fi

	local ip=$(fn_getJSONData "$1" "slass.ip" "-r")
	local otherparams=$(fn_getJSONData "$1" "slass.otherparams")
	local logfilelifetime=$(fn_getJSONData "$1" "slass.logfilelifetime" "-r")

	local hostname=$(fn_getJSONData "$1" "slass.hostname")
	local hc=$(fn_getJSONData "$1" "slass.headlessClient" "-r")
	local port=$(fn_getJSONData "$1" "slass.port" "-r")

	printf "nhc=$hc" > $scfgi
	printf "\nbasepath=$basepath" >> $scfgi
	printf "\nip=$ip" >> $scfgi
	printf "\nport=$port" >> $scfgi
	printf "\notherparams=$otherparams" >> $scfgi
	printf "\nlogfilelifetime=$logfilelifetime" >> $scfgi
	printf "\nhostname=$hostname" >> $scfgi

	printf "$scfgi"
}