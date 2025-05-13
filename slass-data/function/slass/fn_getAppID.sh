#
# SLASS - fn_getAppID
#
# Author: PhilipJFry
#
# Description:
# Expand given modlist with required mods
#
# Parameter(s):
# 1) Mods <String>
# 2) Case <String>
# 3) Server Number <Number>
#
# Return Value:
# None <Any>
#
fn_getAppID () {
	if [[ -z "$1" ]]; then
		fn_printMessage "$FUNCNAME: No mod names givin, exit!" "" "error"
	else
		local modnamelist
		modnamelist=$1
		
		local mission		

		if [[ ! -z "$3" ]]; then
			fn_printMessage "$FUNCNAME: Mission included" "" "debug"
			
			mission=$(fn_getJSONData "" "first(.server$3.\"class Missions\")")
			fn_printMessage "$FUNCNAME: Mission: $mission" "" "debug"

			if [[ "$mission" == "null" ]] || [[ -z "$mission" ]]; then
				fn_printMessage "$FUNCNAME: No mission found! Read standard mission!" "" "debug"
				mission=$(fn_getJSONData "" "first(.global.\"class Missions\")")
				fn_printMessage "$FUNCNAME: Mission: $mission" "" "debug"

				if [[ "$mission" == "null" ]] || [[ -z "$mission" ]]; then
					fn_printMessage "$FUNCNAME: No global mission defined!" "" "debug"
				else
					mission=$(fn_getJSONData "" "first(.global.\"class Missions\"[] | .template)" "-r")
				fi
			else
				mission=$(fn_getJSONData "" "first(.server$3.\"class Missions\"[] | .template)" "-r")
			fi

			local missionKey
			missionKey=$(fn_getJSONData "" ".global.slass.missionrepo | map_values(select(contains({\"filename\": \"$mission\"}))) | keys[]" "-r")
			fn_printMessage "$FUNCNAME: missionKey = $missionKey" "" "debug"

			if [[ "$missionKey" != "null" ]] && [[ ! -z "$missionKey" ]]; then
				local requiredMissionMod
				requiredMissionMod=$(fn_getJSONData "" ".global.slass.missionrepo.$missionKey.require | .[]" "-r")

				fn_printMessage "$FUNCNAME: required mission mods: $requiredMissionMod" "" "debug"

				if [[ "$requiredMissionMod" != "null" ]] && [[ ! -z "$requiredMissionMod" ]]; then
					modnamelist+=" $requiredMissionMod"
					fn_printMessage "$FUNCNAME: New modnamelist = $modnamelist" "" "debug"
				fi
			fi
		fi

		modnamelist="${modnamelist//$'\n'/ }"
		modnamelist=$(echo "$modnamelist" | sed -r ':a; s/\b([[:alnum:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')

		local modNameListExtended
		modNameListExtended=""

		for mod in $modnamelist; do
			local requireexist
			requireexist=$(fn_getJSONData "" ".global.slass.modrepo.$mod.require")
			
			if [[ "$modNameListExtended" = "" ]]; then
				modNameListExtended+="$mod"
			else
				modNameListExtended+=" $mod"
			fi

			if [[ "$requireexist" != "null" ]] && [[ ! -z "$2" ]]; then
				local requireModNameListExtended
				requireModNameListExtended=$(fn_getJSONData "" ".global.slass.modrepo.$mod.require[]" "-r")
				
				#local requireModInfo=$(fn_getJSONData "" ".global.slass.modrepo.\"$appid\".require | keys[] as \$k | \"\(\$k) \(.[\$k])\"" "-r")
				local requireModInfo
				requireModInfo="${requireModNameListExtended//$'\n'/ }"
				
				fn_printMessage "$FUNCNAME: Required mods found! [$requireModInfo] will be added to loaded mods if they are not in there!" "" "warning"

				if [[ "$modNameListExtended" = "" ]]; then
					modNameListExtended+="$requireModInfo"
				else
					modNameListExtended+=" $requireModInfo"
				fi
			fi
		done

		modNameListExtended=$(echo "$modNameListExtended" | sed -r ':a; s/\b([[:graph:]]+)\b(.*)\b\1\b/\1\2/g; ta; s/(, )+/, /g; s/, *$//')
		modNameListExtended="${modNameListExtended//$'\n'/ }"
		
		returnValue="$modNameListExtended"
	fi
}