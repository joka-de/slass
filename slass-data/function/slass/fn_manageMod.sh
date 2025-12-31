# SLASS - fn_manageMod
#
# Author: PhilipJFry
#
# Description:
# Update, set hostname, link and load mods
#
# Parameter(s):
# 1) Case <String> - update, hostname, startup, linkkey
# 2) List of mods <String>
# 3) Sever number <Integer> - case linkkey
# 4) Repo <String> - modrepo, missionrepo
#
# Return Value:
# None <Any>
#
fn_manageMod () {
	fn_getFunctionStatus $FUNCNAME

	if [[ "$4" != "modrepo" ]] && [[ "$4" != "missionrepo" ]]; then
		fn_printMessage "$FUNCNAME: Wrong json config object! \$4 = $4" "" "error"
		exit 1
	fi

	local configObject
	configObject=$4

	fn_printMessage "$FUNCNAME: configObject: $configObject" "" "debug"

	local modlist
	modlist=$2
	modlist="${modlist//$'\n'/ }"

	fn_printMessage "$FUNCNAME: Case: $1, Mods: $modlist" "" "debug"

	if [[ -z "$1" ]]; then
		fn_printMessage "$FUNCNAME: Case was not provided! Exit!" "" "error"
		exit 1
	fi

	if [[ -z "$modlist" ]]; then
		fn_printMessage "$FUNCNAME: No mods provided!" ""
	else
		local linkmod
		linkmod=""

		local hostname_mods
		hostname_mods=""
		#local re='^[0-9]+$'

		for mod in $modlist; do
			local appid
			appid=$(fn_getJSONData "" ".global.slass.$configObject.$mod.appid" "-r")
			
			local apptype
			apptype=""
			
			if [[ "$configObject" = "modrepo" ]]; then
				apptype=$(fn_getJSONData "" ".global.slass.modrepo.$mod.apptype" "-r")
			fi
			
			case "$1" in
				update)
					if [[ "$appid" != "local" ]]; then
						local lastupdatelocal
						lastupdatelocal=$(fn_getJSONData "" ".global.slass.$configObject.$mod.lastupdate")
						
						local lastupdateonline
						lastupdateonline=0

						if [[ "$lastupdatelocal" != "null" ]]; then
							lastupdateonline=$(curl -s --data "itemcount=1&publishedfileids[0]=$appid" https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/ | jq '.response.publishedfiledetails[].time_updated' -r)
						else
							lastupdatelocal=0
						fi

						fn_printMessage "$FUNCNAME: mod = $mod | lastupdatelocal = $lastupdatelocal | lastupdateonline = $lastupdateonline" "" "debug"

						if (( $lastupdatelocal <= $lastupdateonline )) || (( $lastupdatelocal == 0 )); then
							if [[ "$linkmod" = "" ]]; then
								linkmod+="$mod"
							else
								linkmod+=" $mod"
							fi

							local currenttimestamp
							currenttimestamp=$(date +%s)							
							
							local tmpfile
							tmpfile=$(mktemp --tmpdir=$basepath file.XXXXX)
							
							chmod 700 $tmpfile
							echo "@ShutdownOnFailedCommand 1
							@NoPromptForPassword 1
							force_install_dir $basepath
							login $usersteam $steampassword" >> $tmpfile
							echo "workshop_download_item 107410 "$appid" validate" >> $tmpfile
							echo "quit" >> $tmpfile
							
							local download_status
							download_status=1
							
							local counter
							counter=1

							until [ "$download_status" == "0" ]; do
								fn_printMessage "--- Attempt $counter downloading app $mod - $appname ---" ""

								$basepath/steamcmd/steamcmd.sh +runscript $tmpfile | sed -u "s/$steampassword/----/g" | awk 'BEGIN{s=0} /ERROR/{s=1} 1; END{exit(s)}' &
								local steampid
								steampid=$!
								wait $steampid
								download_status=$?

								if ((counter > 4)); then
									fn_printMessage "Steam returned $counter consecutive errors. [$appname, $mod] Exiting." ""
									sleep 2s
									exit 1
								fi

								((counter++))
							done

							fn_printMessage "$FUNCNAME: download_status: $download_status" "" "debug"
							fn_getJSONData "" ".global.slass.$configObject.$mod.lastupdate=$currenttimestamp" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json

							rm $tmpfile
						else
							fn_printMessage "$FUNCNAME: lastupdatelocal = $lastupdatelocal | lastupdateonline = $lastupdateonline" "" "debug"
							fn_printMessage "No update available for $mod" ""
						fi
					fi
				;;

				hostname)
					local inServerName
					inServerName=$(fn_getJSONData "" ".global.slass.modrepo.$mod.inservername" "-r")

					if [[ "$inServerName" != "null" ]] && [[ ! -z "$inServerName" ]]; then
						if [[ "$hostname_mods" = "" ]]; then
							hostname_mods=$hostname_mods" $inServerName"
						else
							hostname_mods=$hostname_mods", $inServerName"
						fi
					else
						inServerName="empty/not defined"
					fi

					fn_printMessage "$FUNCNAME: appname = $mod | appid = $appid | inservername = $inServerName" "" "debug"
				;;

				linkkey)
					if [[ -z "$3" ]]; then
						fn_printMessage "$FUNCNAME: Server number not provided! \$3 = $3" "" "error"
						exit 1
					fi

					fn_printMessage "$FUNCNAME: appname = $mod | appid = $appid | apptype = $apptype" "" "debug"

					if [[ "$apptype" != "smod" ]]; then
						fn_printMessage "$FUNCNAME: copied $mod-key to server $3" "" "debug"

						case "$mod" in
							gm|vn|csla|ws|spe|rf|ef)
								ln -s $basepath/a3/a3master/keys/$mod.bikey $basepath/a3/a3srv$3/keys/
							;;
							*)
								find $basepath/a3/a3master/_mods/@$mod/key*/ -type f -name "*.bikey" -exec ln -sf {} $basepath/a3/a3srv$3/keys/ \;
							;;
						esac
					fi
				;;

				startup)
					fn_printMessage "$FUNCNAME: appname = $mod | appid = $appid | apptype = $apptype" "" "debug"

					if [[ "$apptype" = "mod" ]]; then
						case "$mod" in
							gm|vn|csla|ws|spe|rf|ef)
								mods=${mods}${mod}";"
							;;
							*)
								mods=${mods}"_mods/@"${mod}";"
							;;
						esac
					fi

					if [[ "$apptype" = "smod" ]]; then
							servermods=${servermods}"_mods/@"${mod}";"
					fi
				;;

				*)
					fn_printMessage "$FUNCNAME: No case provided! Exit" "" "error"
					exit 1
				;;
			esac
		done

		if [[ "$linkmod" != "" ]]; then
			if [[ "$configObject" = "modrepo" ]]; then
				fn_printMessage "$FUNCNAME: linkmod: \"$linkmod\"" "" "debug"
				
				for link in $linkmod; do
					fn_printMessage "$FUNCNAME: link: $linkmod" "" "debug"
					find $basepath/a3/a3master/_mods/@$link -type l -delete 2>/dev/null
					
					local appid
					appid=$(fn_getJSONData "" ".global.slass.modrepo.$link.appid" "-r")				

					fn_printMessage "  ... make symlink for app $appid to $link" ""
					ln -s $basepath/steamapps/workshop/content/107410/$appid $basepath/a3/a3master/_mods/@$link

					fn_printMessage "  ... renaming $link to lowercase" ""
					find -L $basepath/a3/a3master/_mods/@$link -depth -execdir rename -f 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
					fn_printMessage "  ... renaming $link done" ""
				done
			else
				fn_printMessage "$FUNCNAME: linkmod: \"$linkmod\"" "" "debug"

				for link in $linkmod; do
					fn_printMessage "$FUNCNAME: link: $linkmod" "" "debug"
					
					local appid
					appid=$(fn_getJSONData "" ".global.slass.$configObject.$link.appid" "-r")				

					local missionfoldername
					missionfoldername=$(find $basepath/steamapps/workshop/content/107410/$appid -type f -name *.bin)
					missionfoldername=$(basename $missionfoldername)
					missionfoldername=$(echo $missionfoldername | sed -e 's/_legacy.bin//')
					
					local missionDownloadFolder
					missionDownloadFolder=$(find /home/$USER/Steam/userdata -type d -name ugc)

					local missionpbopath					
					missionpbopath=$(find $missionDownloadFolder/referenced/$missionfoldername -type f -name *.pbo)
					
					local missionpbo
					missionpbo=$(basename $missionpbopath)
					missionpbo=$(echo $missionpbo | sed -e 's/%2f//g' -e 's/%20//g' | tr '[:upper:]' '[:lower:]')

					fn_printMessage "  ... copy mission $missionpbo to mpmissions" ""
					cp $missionpbopath $basepath/a3/a3master/mpmissions/$missionpbo

					local filenameEntryExist
					filenameEntryExist=$(fn_getJSONData "" ".global.slass.$configObject.$link.filename" "-r")

					if [[ "$filenameEntryExist" != "null" ]]; then
						fn_printMessage "Filename of mission $link will be overwriten: filename = $missionpbo" ""
						fn_getJSONData "" ".global.slass.$configObject.$link.filename = \"$missionpbo\"" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json
					else
						fn_printMessage "Filename of mission $link will be added: filename = $missionpbo" ""
						fn_getJSONData "" ".global.slass.$configObject.\"$link\" += {\"filename\" : \"$missionpbo\"}" > $basepath/config/server~.json && mv $basepath/config/server~.json $basepath/config/server.json
					fi
				done
			fi
		fi

		if [[ "$1" = "hostname" ]]; then
			if [[ "$hostname_mods" == "" ]]; then
				hostname_mods=" Vanilla"
			fi

			fn_printMessage "$FUNCNAME: hostname_mods: $hostname_mods" "" "debug"

			returnValue="$hostname_mods"
		fi
	fi
}
