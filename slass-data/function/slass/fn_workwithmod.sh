#
# SLASS - fn_workwithmod
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
#
# Return Value:
# None <Any>
#
fn_workwithmod () {
	fn_getFunctionStatus $FUNCNAME

	fn_printMessage "$FUNCNAME: Case: $1, Mods: $2" "" "debug"

	if [[ -z "$1" ]]; then
		fn_printMessage "$FUNCNAME: Case was not provided! Exit!" "" "error"
		exit 1
	fi

	if [[ -z "$2" ]]; then
		fn_printMessage "$FUNCNAME: No mods provided!" ""
	else
		local linkmod=""
		local hostname_mods=""

		for mod in $2; do
			local appname=$mod
			local appid=$(fn_getJSONData "" "global.slass.modrepo.$appname.appid" "-r")
			local apptype=$(fn_getJSONData "" "global.slass.modrepo.${appname}.apptype" "-r")

			case "$1" in
				update)
					if [[ "$appid" != "local" ]]; then
						if [[ "$linkmod" = "" ]]; then
							linkmod+="$appname"
						else
							linkmod+=" $appname"
						fi

						local tmpfile=$(mktemp --tmpdir=$basepath file.XXXXX)
						chmod 700 $tmpfile
						echo "@ShutdownOnFailedCommand 1
						@NoPromptForPassword 1
						force_install_dir ${basepath}
						login $usersteam $steampassword" >> $tmpfile
						echo "workshop_download_item 107410 "${appid}" validate" >> $tmpfile
						echo "quit" >> $tmpfile
						local download_status=1
						local counter=1

						until [ "${download_status}" == "0" ]; do
							fn_printMessage "--- Attempt ${counter} downloading app ${appid} - ${appname} ---" ""

							${basepath}/steamcmd/steamcmd.sh +runscript $tmpfile | sed -u "s/${steampassword}/----/g" | awk 'BEGIN{s=0} /ERROR/{s=1} 1; END{exit(s)}' &
							local steampid=$!
							wait $steampid
							download_status=$?

							if ((counter > 4)); then
								fn_printMessage "Steam returned ${counter} consecutive errors. [${appname}, ${appid}] Exiting." ""
								sleep 2s
								exit 1
							fi

							((counter++))
						done

						fn_printMessage "$FUNCNAME: download_status: ${download_status}" "" "debug"

						rm $tmpfile
					fi
				;;

				hostname)
					local inservername=$(fn_getJSONData "" "global.slass.modrepo.${appname}.inservername" "-r")

					if [[ "$inservername" != "null" ]] && [[ ! -z "$inservername" ]]; then
						if [[ "${hostname_mods}" = "" ]]; then
							hostname_mods=${hostname_mods}" ${inservername}"
						else
							hostname_mods=${hostname_mods}", ${inservername}"
						fi
					else
						inservername="empty/not defined"
					fi

					fn_printMessage "$FUNCNAME: appname = ${appname} | appid = ${appid} | inservername = ${inservername}" "" "debug"
				;;

				linkkey)
					if [[ -z "$3" ]]; then
						fn_printMessage "$UNCNAME: Server number not provided! \$3 = $3" "" "error"
						exit 1
					fi

					fn_printMessage "$FUNCNAME: appname = ${appname} | appid = ${appid} | apptype = ${apptype}" "" "debug"

					if [[ "${apptype}" != "smod" ]]; then
						fn_printMessage "$FUNCNAME: copied ${appname}-key to server ${3}" "" "debug"

						case "$appname" in
							gm|vn|csla|ws|spe|rf|ef)
								ln -s ${basepath}/a3/a3master/keys/${appname}.bikey ${basepath}/a3/a3srv${3}/keys/
							;;
							*)
								find ${basepath}/a3/a3master/_mods/@${appname}/ -type f -name "*.bikey" -exec ln -sf {} ${basepath}/a3/a3srv${3}/keys/ \;
							;;
						esac
					fi
				;;

				startup)
					fn_printMessage "$FUNCNAME: appname = ${appname} | appid = ${appid} | apptype = ${apptype}" "" "debug"

					if [[ "${apptype}" = "mod" ]]; then
						case "$appname" in
							gm|vn|csla|ws|spe|rf|ef)
								mods=${mods}${appname}";"
							;;
							*)
								mods=${mods}"_mods/@"${appname}";"
							;;
						esac
					fi

					if [[ "${apptype}" = "smod" ]]; then
							servermods=${servermods}"_mods/@"${appname}";"
					fi
				;;

				*)
					fn_printMessage "$FUNCNAME: No case provided! Exit" "" "error"
					exit 1
				;;
			esac
		done

		if [[ "$linkmod" != "" ]]; then
			fn_printMessage "$FUNCNAME: linkmod: \"$linkmod\"" "" "debug"
			find ${basepath}/a3/a3master/_mods/ -maxdepth 1 -type l -delete

			for link in $linkmod; do
				appid=$(fn_getJSONData "" "global.slass.modrepo.$link.appid")

				fn_printMessage "  ... make symlink for app ${appid} to ${link}" ""
				ln -s ${basepath}/steamapps/workshop/content/107410/${appid} ${basepath}/a3/a3master/_mods/@${link}
			done
		fi

		if [[ "$1" == "hostname" ]]; then
			if [[ "$hostname_mods" == "" ]]; then
				hostname_mods=" Vanilla"
			fi

			fn_printMessage "$FUNCNAME: hostname_mods: $hostname_mods" "" "debug"

			returnValue="$hostname_mods"
		fi
	fi
}