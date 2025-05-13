#
# SLASS - fn_removeWSItem
#
# Author: PhilipJFry
#
# Description:
# Remove unnecessary workshop items from requierd entry in server.json
#
# Parameter(s):
# 1) Workshop Item ID <String>
#
# Return Value:
# None <Any>
#
fn_removeWSItem() {
	fn_getFunctionStatus $FUNCNAME

	local rwsItemIDAllInWS
	rwsItemIDAllInWS=$1

	local wsItemName
	wsItemName=$2

	local configObject
	configObject=$3

	local rwsItemIDAllInWSCount
	rwsItemIDAllInWSCount=$(echo "$rwsItemIDAllInWS" | wc -w)

	local rwsItemIDAllInConfig
	rwsItemIDAllInConfig=$(fn_getJSONData "" ".global.slass.$configObject.$wsItemName.require | keys[]" "-r")

	rwsItemIDAllInConfig="${rwsItemIDAllInConfig//$'\n'/ }"

	local rwsItemIDAllInConfigCount
	rwsItemIDAllInConfigCount=$(echo "$rwsItemIDAllInConfig" | wc -w)

	if (( $rwsItemIDAllInConfigCount > $rwsItemIDAllInWSCount )); then
		fn_printMessage "Unnecessary dependencies found! for $wsItemName!" "" "warning"

		for rwsItemIDInWS in $rwsItemIDAllInWS; do
			rwsItemIDAllInConfig=$(echo "$rwsItemIDAllInConfig" | sed -e "s/$rwsItemIDInWS//")
		done

		fn_printMessage "The required mods [${rwsItemIDAllInConfig}] will be deleted from mod ${wsItemName}!" "" "warning"

		for rwsItemIDInConfig in $rwsItemIDAllInConfig; do
			fn_getJSONData "" "del(.global.slass.$configObject.$wsItemName.require.\"$rwsItemIDInConfig\")" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json						
		done
	else
		fn_printMessage "No unnecessary dependencies found for $wsItemName!" "" "debug"
	fi
}