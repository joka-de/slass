# SLASS - fn_manageWSItem
#
# Author: PhilipJFry
#
# Description:
# Search for dependencies, unknown workshop items and update server.json
#
# Parameter(s):
# 1) Case <String> - modrepo, missionrepo
#
# Return Value:
# None <Any>
#
fn_manageWSItem() {
	fn_getFunctionStatus "$FUNCNAME"

	if [[ "$1" != "modrepo" ]] && [[ "$1" != "missionrepo" ]]; then
		fn_printMessage "$FUNCNAME: Wrong json config object! \$1 = $1" "" "error"
		exit 1
	fi
	
	local configObject
	configObject=$1
	
	fn_printMessage "$FUNCNAME: configObject: $configObject" "" "debug"

	local wsItemNameAllInConfig
	wsItemNameAllInConfig=$(fn_getJSONData "" ".global.slass.$configObject | keys[]" "-r")
	
	for wsItemName in $wsItemNameAllInConfig; do
		local wsItemID
		wsItemID=$(fn_getJSONData "" ".global.slass.$configObject.$wsItemName.appid" "-r")

		if [[ "$wsItemID" != "local" ]]; then
			local rwsItemIDAllInWS
			rwsItemIDAllInWS=$(curl -s "https://steamcommunity.com/workshop/filedetails/?id=$wsItemID" | sed -n 's/.*<a href="https:\/\/steamcommunity.com\/workshop\/filedetails\/?id=\([0-9]*\).*/\1/p')

			# remove linebreaks with whitespaces
			rwsItemIDAllInWS="${rwsItemIDAllInWS//$'\n'/ }"

			if [[ -z "$rwsItemIDAllInWS" ]]; then
				fn_printMessage "No dependencies found for $wsItemName | $wsItemID" ""
			else
				fn_printMessage "Workshop item(s) found for $wsItemName | $wsItemID | IDs = [$rwsItemIDAllInWS]" ""

				for rwsItemID in $rwsItemIDAllInWS; do
					fn_checkRequiredWSItem "$wsItemName" "$rwsItemID" "$configObject"
				done

				fn_removeWSItem "$rwsItemIDAllInWS" "$wsItemName" "$configObject"
			fi
		else
			fn_printMessage "$wsItemName is a local mod and will be skipped!" ""
		fi
	done
}