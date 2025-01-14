#
# SLASS - keylinker
#
# Author: seelenlos
#
# Description:
# creates creates symlinks to the appropiate keys for server instance { i }
#
# Parameter(s):
# 1. server id {i} <integer>
#
# Return Value:
# None <Any>
#
# a3 basegame key
ln -s ${basepath}/a3/a3master/keys/a3.bikey ${basepath}/a3/a3srv${1}/keys/

# mod keys
mods=$(fn_getJSONData "" "global.slass.modtoload + .server${1}.slass.modtoload | .[]" "-r")

for mod in $mods; do
	appname=$mod
	apptype=$(fn_getJSONData "" "global.slass.modrepo.${appname}.apptype" "-r")
	appid=$(fn_getJSONData "" "global.slass.modrepo.${appname}.appid")

	fn_printMessage "m_keylinker: appname = ${appname} | appid = ${appid} | apptype = ${apptype}" "" "debug"

	if [[ "${apptype}" != "smod" ]]; then
		fn_printMessage "m_keylinker: copied ${appname}-key to server ${1}" "" "debug"

		case "$appname" in
			gm|vn|csla|ws|spe|rf|ef)
				ln -s ${basepath}/a3/a3master/keys/${appname}.bikey ${basepath}/a3/a3srv${1}/keys/
			;;
			*)
				find ${basepath}/a3/a3master/_mods/@${appname}/ -type f -name "*.bikey" -exec ln -sf {} ${basepath}/a3/a3srv${1}/keys/ \;
			;;
		esac
	fi
done