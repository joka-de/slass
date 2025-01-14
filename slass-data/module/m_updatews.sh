#
# SLASS - m_updatews
#
# Author: joka
#
# Description:
# performs the download of workshop mods for arma3
#
# Parameter(s):
# None <Any>
#
# Return Value:
# None <Any>
#
# duplex output to log, clear logfiles older than 7 days
exec &> >(tee ${basepath}/log/a3wsupdate_$(date +%Y-%m-%d_%H-%M-%S).log)
find -L ${basepath}/log -iname "*.log" -mtime 7 -delete

# load Steam Credentials
fn_readuserSteam

if [[ "$usersteam" == "anonymous" ]]; then
	fn_printMessage "To perform workshop downloads please add your steam credentials in the server.json file." "" "warning"
	exit 0
fi

# build steam script file
mods=$(fn_getJSONData "" "global.slass.modrepo | keys.[]" "-r")

for mod in $mods; do
	appname=$mod
	appid=$(fn_getJSONData "" "global.slass.modrepo.$appname.appid" "-r")

	if [[ "$appid" != "local" ]]; then
		tmpfile=$(mktemp --tmpdir=$basepath file.XXXXX)
		chmod 700 $tmpfile
		echo "@ShutdownOnFailedCommand 1
		@NoPromptForPassword 1
		force_install_dir ${basepath}
		login $usersteam $steampassword" >> $tmpfile
		echo "workshop_download_item 107410 "${appid}" validate" >> $tmpfile
		echo "quit" >> $tmpfile
		download_status=1
		counter=1

		until [ "${download_status}" == "0" ]; do
			fn_printMessage "--- Attempt ${counter} downloading app ${appid} - ${appname} ---" ""

			${basepath}/steamcmd/steamcmd.sh +runscript $tmpfile | sed -u "s/${steampassword}/----/g" | awk 'BEGIN{s=0} /ERROR/{s=1} 1; END{exit(s)}' &
			steampid=$!
			wait $steampid
			download_status=$?

			if ((counter > 4)); then
				fn_printMessage "Steam returned ${counter} consecutive errors. [${appname}, ${appid}] Exiting." ""
				sleep 2s
				exit 1
			fi

			((counter++))
		done

		fn_printMessage "m_updatews: download_status: ${download_status}" "" "debug"

		rm $tmpfile
	fi
done

find ${basepath}/a3/a3master/_mods/ -maxdepth 1 -type l -delete

for mod in $mods; do
	appname=$mod
	appid=$(fn_getJSONData "" "global.slass.modrepo.$appname.appid" "-r")

	if [[ "$appid" != "local" ]]; then
		fn_printMessage "  ... make symlink for app ${appid} to ${appname}" ""
		ln -s ${basepath}/steamapps/workshop/content/107410/${appid} ${basepath}/a3/a3master/_mods/@${appname}
	fi
done
fn_tolowercase $basepath/a3/a3master/_mods/