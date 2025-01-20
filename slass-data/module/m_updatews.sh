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
mods=$(fn_getJSONData "" "global.slass.modrepo | keys[]" "-r")

fn_workwithmod "update" "$mods"

fn_tolowercase $basepath/a3/a3master/_mods/