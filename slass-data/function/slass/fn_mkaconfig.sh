#
# SLASS - fn_mkaconfig
#
# Author: Fry
#
# Description:
# create configs for server instance a3srv{i}
#
# Parameter(s):
# 1. server id {i} <integer>
#
# Return Value:
# None <Any>
#
fn_mkaconfig () {
	fn_getFunctionStatus $FUNCNAME
	fn_printMessage "$FUNCNAME: start" "" "debug"

	local jsonData=$(fn_getJSONData "1")

	if [[ "$jsonData" = "null" ]]; then
		fn_printMessage "Server ${1} not exist. Please add the server to server.json file" "" "error"
	else
		local cfgi="${basepath}/a3/a3master/cfg/a3srv${1}.cfg"
		fn_printMessage "$FUNCNAME: cfg file $cfgi" "" "debug"

		if [[ -f "$cfgi" ]]; then
			rm $cfgi
		fi

		if [[ -f "${basepath}/a3/a3master/cfg/basic.cfg" ]]; then
			rm "${basepath}/a3/a3master/cfg/basic.cfg"
		fi

		cp "${basepath}/config/basic.cfg" "${basepath}/a3/a3master/cfg/basic.cfg"

		jq '.global * .server'"$1"' | del(.slass, ._comment)' ${basepath}/config/server.json | sed \
			-e 's/^.\{4\}$/  };/g' \
			-e 's|^[{}]||g' \
			-e '/"class [a-zA-Z0-9"]*:/,/},/{s/}/};/}' \
			-e 's/};;/};/g' \
			-e 's/"*": /=/g' \
			-e '/"[a-zA-Z0-9 _]*=/{s/"//}' \
			-e '/"[a-zA-Z0-9_]*\[\]=/{s/"//}' \
			-e '/[a-zA-Z]=[a-z0-9"]/{s/,/;/}' \
			-e '/[a-zA-Z]=[a-z0-9"]* *$/s/$/;/' \
			-e '/\[[a-zA-Z0-9",]*/,/\};/{s/\],/\},/g}' \
			-e '/\[[a-zA-Z0-9",]*/,/\};/{s/\[/\{/g}' \
			-e '/\[[a-zA-Z0-9",]*/,/\};/{s/\[/\{/g}' \
			-e '/{[a-zA-Z0-9",]*/,/\};/{s/\]/\}/g}' \
			-e '/[a-zA-Z0-9_]*{}=/{s/{}/\[\]/}' \
			-e 's/{},/{};/g' \
			-e '/class [a-zA-Z0-9]*=/{s/=/ /}' \
			-e 's/^..//' \
        	-e '/^[[:space:]]*$/d' \
        	-e '/template/,/;/{s/{/\[/}' \
        	-e '/template/,/;/{s/}/\]/}' \
        >> $cfgi

        # make modlist
		local hostname_mods=""

		local mods=$(fn_getJSONData "" "global.slass.modtoload + .server${1}.slass.modtoload | .[]" "-r")

		for mod in $mods; do
			local appname=$mod
			local appid=$(fn_getJSONData "" "global.slass.modrepo.${appname}.appid")

			fn_printMessage "$FUNCNAME: appname = ${appname} | appid = ${appid}" "" "debug"

			local inservername=$(fn_getJSONData "" "global.slass.modrepo.${appname}.inservername" "-r")

			fn_printMessage "$FUNCNAME: inservername: $inservername" "" "debug"

			if [[ "$inservername" != "null" ]] && [[ ! -z "$inservername" ]]; then
				if [[ "${hostname_mods}" = "" ]]; then
					hostname_mods=${hostname_mods}" ${inservername}"
				else
					hostname_mods=${hostname_mods}", ${inservername}"
				fi

				fn_printMessage "$FUNCNAME: hostname_mods: $hostname_mods" "" "debug"
			fi
		done

		if [[ "${hostname_mods}" = "" ]]; then
			hostname_mods=" Vanilla"
		fi

		local hostname=$(fn_getJSONData "$1" "slass.hostname" "-r")
		hostname+=$hostname_mods
		fn_printMessage "$FUNCNAME: $hostname" "" "debug"
		sed -i "1 i\hostname=\"$hostname\";" $cfgi
	fi

	fn_printMessage "$FUNCNAME: end" "" "debug"
}