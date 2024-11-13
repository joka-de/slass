#
# SLASS - fn_getVar
#
# Author: PhilipJFry
#
# Description:
# Get and return value from json file
#
# Parameter(s):
# Top-Level <String>
# Second-Level <String>
# Filename <String>
# 
# Example(s):
# output=$(fn_getVar "server1" "port" "server.json")
# output=$(fn_getVar "server1" "Missions.MissionRotation1.params" "server.json")
# output=$(fn_getVar "global" "persistent" "server.json")
# output=$(fn_getVar "global.persistent")
# output=$(fn_getVar "global.persistent" "" "server.json")
#	
# Return Value:
# Any <String>
#
fn_getVar () {
	local serverFile=""

	if [[ -z $3 ]]; then
		serverFile="${basepath}/config/server.json"
	else
		serverFile="${basepath}/config/$3"
	fi

	local output=""

	if [[ -z $2 ]]; then
		output=$(jq '.'$1'' $serverFile)
	else
		output=$(jq '.'$1'.'$2'' $serverFile)
	fi

	echo $output
}