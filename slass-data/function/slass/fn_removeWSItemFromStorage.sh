#
# SLASS - fn_removeWSItemFromStorage
#
# Author: PhilipJFry
#
# Description:
# Remove unnecessary workshop items from storage
#
# Parameter(s):
# 1) Workshop Item ID <String>
#
# Return Value:
# None <Any>
#
fn_removeWSItemFromStorage() {
	fn_getFunctionStatus $FUNCNAME

	for folder in $basepath/steamapps/workshop/content/107410/*/; do
		local appid
		appid=$(basename "$folder")
		
		local wsItem
		wsItem=$(fn_getJSONData "" ".global.slass.modrepo[] | select(.appid == $appid)")

		if [[ "$wsItem" != "null" ]] && [[ ! -z "$wsItem" ]]; then
			fn_printMessage "$FUNCNAME: wsItem $appid found in modrepo!" ""
		else
			fn_printMessage "$FUNCNAME: wsItem $appid not found in modrepo! Checking missionrepo!" ""

			local wsItemMission
			wsItemMission=$(fn_getJSONData "" ".global.slass.missionrepo[] | select(.appid == $appid)")

			if [[ "$wsItemMission" != "null" ]] && [[ ! -z "$wsItemMission" ]]; then
				fn_printMessage "$FUNCNAME: wsItem $appid found in missionrepo!" ""
			else
				fn_printMessage "$FUNCNAME: wsItem $appid not found in missionrepo!" ""
				
				local isMission 
				isMission=$(find "$folder" -type f -name *_legacy.bin)

				if [[ -z "$isMission" ]]; then
					fn_printMessage "$FUNCNAME: $folder deleted!" ""
					rm -rf "$folder"

					local brokenSymlink
					brokenSymlink=$(find ./slass/a3/a3master/_mods/ -xtype l)

					if [[ ! -z "$brokenSymlink" ]]; then
						rm -rf "$brokenSymlink"
					fi
				else
					local missionfoldername
					missionfoldername=$(basename $isMission)
					missionfoldername=$(echo $missionfoldername | sed -e 's/_legacy.bin//')
					
					local missionDownloadFolder
					missionDownloadFolder=$(find /home/$USER/Steam/userdata -type d -name ugc)
					
					fn_printMessage "$FUNCNAME: $folder deleted!" ""
					rm -rf "$folder"
					fn_printMessage "$FUNCNAME: $missionDownloadFolder/referenced/$missionfoldername deleted!" ""	
					rm -rf "$missionDownloadFolder/referenced/$missionfoldername"
					rm -f "$basepath/steamapps/workshop/appworkshop_107410.acf"
				fi
			fi
		fi
	done
} 