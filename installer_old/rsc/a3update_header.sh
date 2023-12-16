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
