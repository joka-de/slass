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
