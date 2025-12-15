#
# SLASS - fn_checkRequiredWSItem
#
# Author: PhilipJFry
#
# Description:
# Search for dependencies, unknown workshop items and update server.json
#
# Parameter(s):
# 1) Workshop Item ID <String>
#
# Return Value:
# None <Any>
#
fn_checkRequiredWSItem() {
	fn_getFunctionStatus $FUNCNAME

	local wsItemName
	wsItemName=$1

	local rwsItemID
	rwsItemID=$2

	local configObject
	configObject=$3

	local rwsItemNameInConfig
	rwsItemNameInConfig=$(fn_getJSONData "" ".global.slass.modrepo | map_values(select(contains({\"appid\": $rwsItemID}))) | keys[]" "-r")

	local rwsItemNameInWS
	rwsItemNameInWS=$(curl -s --data "itemcount=1&publishedfileids[0]=${rwsItemID}" https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/ | jq '.response.publishedfiledetails[].title' -r)

	# remove every character that's not compatible with json
	rwsItemNameInWS=$(echo "$rwsItemNameInWS" | sed -e 's/\(.*\)/\L\1/' -e 's/ /_/g' -e 's/[][]//g' -e "s/'//g" -e 's/://g' -e 's/-//g' -e 's/,//g')
	
	local rwsItemName
	rwsItemName=$rwsItemNameInWS

	if [[ "$rwsItemNameInConfig" != "null" ]] && [[ ! -z "$rwsItemNameInConfig" ]]; then
		fn_printMessage "Required mod ${rwsItemNameInConfig} found in your mod repository! $rwsItemNameInConfig | $rwsItemID" ""
		rwsItemName=$rwsItemNameInConfig
	else
		fn_printMessage "Mod ${rwsItemName} not found in your mod repository!" ""
		fn_printMessage "Creating new mod entry! mod = ${rwsItemName} | appid = ${rwsItemID}" ""
		fn_printMessage "Please repeat the workshop update after you change the modname!" "" "warning"
		fn_getJSONData "" ".global.slass.modrepo += {\"$rwsItemName\": {_comment: \"$rwsItemName\", appid: $rwsItemID, apptype: \"mod\", inservername: \"\"}}" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json
	fi

	local requireEntryExist
	requireEntryExist=$(fn_getJSONData "" ".global.slass.$configObject.$wsItemName.require")

	if [[ "$requireEntryExist" != "null" ]]; then
		local rwsItemInRequire
		rwsItemInRequire=$(fn_getJSONData "" ".global.slass.$configObject.$wsItemName.require.\"$rwsItemID\"" "-r")
		
		if [[ "$rwsItemInRequire" != "null" ]]; then
			if [[ "$rwsItemInRequire" != "$rwsItemName" ]]; then
				fn_printMessage "Required mod ${rwsItemID}: name changed to ${rwsItemName} and will be updated for the mod ${wsItemName}!" ""
				fn_getJSONData "" ".global.slass.$configObject.$wsItemName.require.\"$rwsItemID\" = \"$rwsItemName\"" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json

				fn_renewWSItemLink "$rwsItemID" "$rwsItemName"
			else
				fn_printMessage "Mod ${rwsItemInRequire} is already a dependencie for ${wsItemName}!" "" "debug"
			fi
		else
			fn_printMessage "Required mod ${rwsItemName} will be added for the mod ${wsItemName}!" ""
			fn_getJSONData "" ".global.slass.$configObject.$wsItemName.require += {\"$rwsItemID\" : \"$rwsItemName\"}" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json
		fi
	else
		fn_printMessage "Required mod ${rwsItemName} will be added for the mod ${wsItemName}!" ""
		fn_getJSONData "" ".global.slass.$configObject.\"$wsItemName\" += {\"require\" : {\"$rwsItemID\" : \"$rwsItemName\"}}" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json
	fi
}