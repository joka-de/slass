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
fn_manageWSItem "modrepo"
fn_manageWSItem "missionrepo"

mods=$(fn_getJSONData "" ".global.slass.modrepo | keys[]" "-r")
fn_manageMod "update" "$mods" "" "modrepo"

missions=$(fn_getJSONData "" ".global.slass.missionrepo | keys[]" "-r")
fn_manageMod "update" "$missions" "" "missionrepo"

fn_removeWSItemFromStorage