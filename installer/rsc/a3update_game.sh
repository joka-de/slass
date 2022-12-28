
# build steam script file - game
tmpfile=$(mktemp)
echo "@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${a3instdir}/a3master
login $user $pw" >> $tmpfile
if [ "${execdownload}" == "y" ]; then
	echo 'app_update 233780 -beta creatordlc " validate' >> $tmpfile
fi
echo "quit" >> $tmpfile
chmod 770 $tmpfile

# update game
${steamdir}/steamcmd.sh +runscript $tmpfile | sed -u "s/${pw}/----/g" &
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
