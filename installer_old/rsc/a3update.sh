execdownload="y"

# duplex output to log
exec &> >(tee ${a3instdir}/scripts/logs/a3update.log)

echo "
In case the download of the game or a mod fails with a timeout, just start runupdate.sh again and again.
This is a known bug of steamcmd in when a download takes long (esp. large mods).

You will now need a steam-user with A3 and the mods subscribed.

Please enter the username of the Steam-User used for the A3-Update:"
read user
echo "Please enter the Steam-Password for $user:"
read -s pw

echo -n "  ... halt servers"
# halt server(s)
for index in $(seq 3); do
        sudo service a3srv${index} stop
	echo -n " #${index}"
	sleep 2s
done
echo $' - DONE\n'

# build steam script file - game
tmpfile=$(mktemp)
echo "@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${a3instdir}/a3master
login $user $pw" >> $tmpfile
if [ "${execdownload}" == "y" ]; then
	echo "app_update 233780 validate" >> $tmpfile
fi
echo "quit" >> $tmpfile

# update game
${steamdir}/steamcmd.sh +runscript $tmpfile | sed -u "s/${pw}/----\n\nEnter two-factor code if used:/g" &
steampid=$!
wait $steampid
rm $tmpfile

# request update halt
goon="n"
while [ "$goon" != "y" ]; do
echo -n "
If you want to manually expand the server with non-workshop mods, missions, etc. now would be the time to do so
in antoher console. Remember to set the appropiate owner and group for the content.
Type y if you are done and want to go on with the update.

Go on? (y)"
read goon
done

# build steam script file - mods
tmpfile=$(mktemp)
echo "@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
DepotDownloadProgressTimeout 600
force_install_dir ${a3instdir}
login $user $pw" >> $tmpfile

while read line; do
        appid=$(echo $line | awk '{ printf "%s", $2 }')
        if [ "${execdownload}" == "y" ]; then
		if [ "${appid}" != "local" ]; then
                	echo "workshop_download_item 107410 "${appid}" validate" >> $tmpfile
        	fi
	fi
done < ${a3instdir}/scripts/modlist.inp

echo "quit"  >> $tmpfile

# update workshop mods
${steamdir}/steamcmd.sh +runscript $tmpfile | sed -u "s/${pw}/----\n\nEnter two-factor code if used:/g" &
steampid=$!
wait $steampid
rm $tmpfile

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


#---------------------
# get rhs incl. keys - obsolete, may be used as template
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsafrf ftp://ftp.rhsmods.org/beta/rhsafrf/
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsafrf/keys/ ftp://ftp.rhsmods.org/beta/keys/rhsafrf.0.4.1.1.bikey
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsusaf ftp://ftp.rhsmods.org/beta/rhsusaf/
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsusaf/keys/ ftp://ftp.rhsmods.org/beta/keys/rhsusaf.0.4.1.1.bikey
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsgref ftp://ftp.rhsmods.org/beta/rhsgref/
#wget -m -nv -nH --cut-dirs=2 --retry-connrefused --timeout=30 -P ${a3instdir}/a3master/_mods/@rhsgref/keys/ ftp://ftp.rhsmods.org/beta/keys/rhsgref.0.4.1.1.bikey


# reset the file permissions in a3master
echo -n " ...reseting the file permissions in a3master"
find -L $a3instdir/a3master -type d -exec chmod 775 {} \;
find -L $a3instdir/a3master -type f -exec chmod 664 {} \;
chmod 774 $a3instdir/a3master/arma3server
find $a3instdir/a3master -iname '*.so' -exec chmod 775 {} \;
echo $' - DONE\n'

# make all mods lowercase
echo -n "  ... renaming mods to lowercase"
find -L ${a3instdir}/a3master/_mods/ -depth -execdir rename -f 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
echo $' - DONE\n'

# (re)create the folders of the instances
for index in $(seq 3); do
        if [ -d "${a3instdir}/a3srv${index}" ]; then
                rm -rf $a3instdir/a3srv${index}
        fi
        mkdir $a3instdir/a3srv${index} --mode=775
        ln -s ${a3instdir}/a3master/* $a3instdir/a3srv${index}/
	rm -f $a3instdir/a3srv${index}/keys
	mkdir $a3instdir/a3srv${index}/keys --mode=775
done

echo -n "  ... start server"
# bring server(s) back up
for index in $(seq 3); do
        sudo service a3srv${index} start
	echo -n " #${index}"
	sleep 3s
done
echo $' - DONE\n'
