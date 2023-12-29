#
# SLASS - m_updategame
# 
# Author: joka
# 
# Description:
# performs the download of updates for arma3
# 
# Parameter(s):
# None <Any>
# 
# Return Value:
# None <Any>
#
# duplex output to log, clear logfiles older than 7 days
exec &> >(tee ${basepath}/log/a3gameupdate_$(date +%Y-%m-%d_%H-%M-%S).log)
find -L ${basepath}/log -iname "*.log" -mtime 7 -delete
#
# load slass.scfg
fn_readuser $basepath/config/server.scfg
#
fn_printMessage " Preparing to download Arma3.
Please enter the username of the Steam-User used for the A3-Update:"
read user
echo "Please enter the Steam-Password for $user:"
read -s pw
#
# build steam script file - game
tmpfile=$(sudo -u $useradm mktemp --tmpdir=$basepath file.XXXXX)
chmod 700 $tmpfile
echo "@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${basepath}/a3/a3master
login $user $pw" >> $tmpfile
echo 'app_update 233780 -beta creatordlc " validate' >> $tmpfile
echo "quit" >> $tmpfile
#
# update game
sudo -u $useradm ${basepath}/steamcmd/steamcmd.sh +runscript $tmpfile | sed -u "s/${pw}/----/g" &
steampid=$!
wait $steampid
rm $tmpfile
#
# restore file permissions
fn_a3filepermissions