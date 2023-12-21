#
# SLASS - keylinker
# 
# Author: seelenlos
# 
# Description:
# creates creates symlinks to the appropiate keys for server instance { i }
# 
# Parameter(s): {i}
# Message <String>
# 
# Return Value:
# None <Any>
#

# a3 basegame key
ln -s ${basepath}/a3/a3master/keys/a3.bikey ${basepath}/a3/a3srv${serverid}/keys/
# mod keys
while read line; do
		appname=$(echo $line | awk '{ printf "%s", $1 }')
		apptype=$(echo $line | awk '{ printf "%s", $3 }')
		appkey=$(echo $line | awk -v var=$(( $serverid + 3 )) '{ printf "%s", $var }' )
		fn_debugMessage "appkey = ${appkey} for ${appname}"
        if [ "${apptype}" != "smod" ] && [ "${appkey}" = "1" ]; then
				fn_debugMessage " ... ${appname}-key on server #${serverid}"
                case "$appname" in
                gm|vn|csla|ws|spe)
                        ln -s ${basepath}/a3/a3master/keys/${appname}.bikey ${basepath}/a3/a3srv${serverid}/keys/
                ;;
                *)
                        find ${basepath}/a3/a3master/_mods/@${appname}/ -type f -name "*.bikey" -exec ln -sf {} ${basepath}/a3/a3srv${serverid}/keys/ \;
                esac
        fi
done < ${basepath}/config/modlist.inp