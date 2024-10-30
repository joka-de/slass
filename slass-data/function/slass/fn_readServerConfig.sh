#
# SLASS - fn_readServerConfig
#
# Author: PhilipJFry
#
# Description:
# Read the server config and declare array for each server and a array with all commen information
#
# Parameter(s):
# None <Any>
# 
# Return Value:
# None <Any>
#
fn_readServerConfig () {
	counter=0

	while read line; do
	    if [[ $line =~ ^"["(.+)"]"$ ]]; then
	    	((counter++))
	        arrname=${BASH_REMATCH[1]}       
	    	declare -gA $arrname
	    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
	        declare -gA ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
	    fi
	done < $basepath/config/server.scfg

	serverCount=$(expr $counter - 1)

	if [[ $serverCount -eq 0 ]]; then
		fn_printMessage "No server defined!" ""
		exit 0
	fi
}