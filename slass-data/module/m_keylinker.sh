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
while read line; do
	appname=$(echo $line | awk '{ printf "%s", $1 }')
	apptype=$(echo $line | awk '{ printf "%s", $3 }')
	appkey=$(echo $line | awk -v var=$(( $1 + 4 )) '{ printf "%s", $var }' )
	
	if [[ -z "$appkey" ]]; then
		fn_printMessage "m_keylinker: No modlist entry found for server ${1}, consider extending modlist"  "" "warning"
		appkey=$(echo $line | awk -v var=$(( 5 )) '{ printf "%s", $var }' )
		fn_printMessage "m_keylinker: ...defaulting to ${appname} = ${appkey}" "" "warning"
	fi
	
	fn_printMessage "m_keylinker: appname = ${appname} | apptype = ${apptype} | appkey = ${appkey}" "" "debug"
	
	if [[ "${apptype}" != "smod" ]] && [[ "${appkey}" = "1" ]]; then
		fn_printMessage "m_keylinker: copied ${appname}-key to server ${1}" "" "debug"
		
		case "$appname" in
			gm|vn|csla|ws|spe)
				ln -s ${basepath}/a3/a3master/keys/${appname}.bikey ${basepath}/a3/a3srv${1}/keys/
			;;
			*)
				find ${basepath}/a3/a3master/_mods/@${appname}/ -type f -name "*.bikey" -exec ln -sf {} ${basepath}/a3/a3srv${1}/keys/ \;
			;;
		esac
	fi
done < ${basepath}/config/modlist.inp