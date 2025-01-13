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

# load Steam Credentials
fn_readuserSteam

if [[ "$usersteam" == "anonymous" ]]; then
	fn_printMessage "To perform install or update arma 3 please add your steam credentials in the server.json file." "" "warning"
	exit 0
fi

# build steam script file - game
tmpfile=$(mktemp --tmpdir=$basepath file.XXXXX)
chmod 700 $tmpfile
echo "@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${basepath}/a3/a3master
login $usersteam $steampassword" >> $tmpfile
echo 'app_update 233780 -beta creatordlc " validate' >> $tmpfile
echo "quit" >> $tmpfile

# update game
${basepath}/steamcmd/steamcmd.sh +runscript $tmpfile | sed -u "s/${steampassword}/----/g" &
steampid=$!
wait $steampid
rm $tmpfile

# restore file permissions
fn_a3filepermissions