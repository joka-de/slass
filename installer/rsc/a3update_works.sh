
# build steam script file - mods

while read line; do
        appid=$(echo $line | awk '{ printf "%s", $2 }')
	appname=$(echo $line | awk '{ printf "%s", $1 }')
        if [ "${execdownload}" == "y" ]; then
		if [ "${appid}" != "local" ]; then
			tmpfile=$(mktemp)
			echo "@ShutdownOnFailedCommand 1
			@NoPromptForPassword 1
			force_install_dir ${a3instdir}
			login $user $pw" >> $tmpfile
                	echo "workshop_download_item 107410 "${appid}" validate" >> $tmpfile
			echo "quit"  >> $tmpfile

			download_status=1
			counter=1
			until [ "${download_status}" == "0" ]; do
				echo "--- Attempt ${counter} downloading app ${appid} - ${appname} ---"
				${steamdir}/steamcmd.sh +runscript $tmpfile | sed -u "s/${pw}/----/g" | awk 'BEGIN{s=0} /ERROR/{s=1} 1; END{exit(s)}' &
				steampid=$!
				wait $steampid
				download_status=$?
#echo "DOWNLOADSTATUS "${download_status}
				if ((counter > 4)); then
				  echo "Steam returned ${counter} consecutive errors. Exiting."
          			  sleep 2s
				  exit 1
        			fi
				((counter++))
			done
			rm $tmpfile
        	fi
	fi
done < ${a3instdir}/scripts/modlist.inp

# (re)make symlinks to the mods
find ${a3instdir}/a3master/_mods/ -maxdepth 1 -type l -delete
while read line; do
        appid=$(echo $line | awk '{ printf "%s", $2 }')
	appname=$(echo $line | awk '{ printf "%s", $1 }')
        if [ "${appid}" != "local" ]; then
		echo "  ... make symlink for app ${appid} to ${appname}"
        	ln -s ${a3instdir}/steamapps/workshop/content/107410/${appid} ${a3instdir}/a3master/_mods/@${appname}
        fi
done < ${a3instdir}/scripts/modlist.inp
