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

		jq '.global * .server'"$1"' | del(.slass, ._comment)' ${basepath}/config/serverSml.json | sed \
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
        >> $cfgi

        # make modlist
		local mods=""
		local servermods=""
		local hostname_mods=""
		
		while read line; do
			local applistname=$(echo $line | awk '{ printf "%s", $2 }')
			local appkey=$(echo $line | awk -v var=$(( $1 + 4 )) '{ printf "%s", $var }' )
			
			if [[ -z "$appkey" ]]; then
				fn_printMessage "$FUNCNAME: No modlist entry found for server ${1}, consider extending modlist" "" "warning"
				appkey=$(echo $line | awk -v var=$(( 5 )) '{ printf "%s", $var }' )
				fn_printMessage "$FUNCNAME: ... defaulting to entry for server 1 = ${appkey}" "" "warning"
			fi
			
			fn_printMessage "$FUNCNAME: applistname = ${applistname} | appkey = ${appkey}" "" "debug"
						
			if [[ "${applistname}" != "xx" ]] && [[ "${appkey}" = "1" ]]; then
				if [[ "${hostname_mods}" = "" ]]; then
					hostname_mods=${hostname_mods}" ${applistname}"
				else
					hostname_mods=${hostname_mods}", ${applistname}"
				fi
			fi
		done < ${basepath}/config/modlist.inp
	
		if [[ "${hostname_mods}" = "" ]]; then
			hostname_mods=" Vanilla"
		fi

		local hostname=$(fn_getJSONData "$1" "slass.hostname" "-r")
		hostname+=$hostname_mods
		fn_printMessage "$FUNCNAME: $hostname" "" "debug"
		sed -i "1 i\hostname=\"$hostname\";" $cfgi
		#sed -i "/^hostname/c\hostname =\"$hostname\"\;" $cfgi
	fi
	
	fn_printMessage "$FUNCNAME: end" "" "debug"
}