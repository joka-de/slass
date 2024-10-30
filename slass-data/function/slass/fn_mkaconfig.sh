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
	fn_debugMessage "$FUNCNAME: start" ""	

	if [[ $# -eq 0 ]]; then 
		fn_debugMessage "$FUNCNAME: Servernumber not provided" ""
	else
		fn_readServerConfig

		if [[ $serverCount -ge $1 ]]; then
			i=$1
			
			cfgi="${basepath}/a3/a3master/cfg/a3srv${1}.cfg"
			fn_debugMessage "$FUNCNAME: cfg file $cfgi" ""
			
			if [[ -f $cfgi ]]; then
				rm $cfgi
			fi

			if [[ -f "${basepath}/a3/a3master/cfg/basic.cfg" ]]; then
				rm "${basepath}/a3/a3master/cfg/basic.cfg"
			fi

			cp "${basepath}/config/a3master.cfg" $cfgi
			cp "${basepath}/config/basic.cfg" "${basepath}/a3/a3master/cfg/basic.cfg"
			
			# make modlist
			mods=""
			servermods=""
			hostname_mods=""
			#
			while read line; do
				applistname=$(echo $line | awk '{ printf "%s", $2 }')
				appkey=$(echo $line | awk -v var=$(( $1 + 4 )) '{ printf "%s", $var }' )
				#
				if [[ -z "$appkey" ]]; then
					fn_printMessage "No modlist entry found for server ${1}, consider extending modlist"
					appkey=$(echo $line | awk -v var=$(( 5 )) '{ printf "%s", $var }' )
					fn_printMessage "... defaulting to entry for server 1 = ${appkey}"
				fi
				#
				fn_debugMessage "$FUNCNAME: applistname = ${applistname} | appkey = ${appkey}"
				#
				#
				if [ "${applistname}" != "xx" ] && [ "${appkey}" = "1" ]; then
					if [ "${hostname_mods}" = "" ]; then
						hostname_mods=${hostname_mods}" ${applistname}"
					else
						hostname_mods=${hostname_mods}", ${applistname}"
					fi
				fi
			done < ${basepath}/config/modlist.inp
			#
			# remove spaces in cfgi
			#sed -i 's/ = /=/g' $cfgi
			#
			# extract hostname from source
			#source <(sed '/^hostname/!d' $cfgi | sed 's/;//')
			#sed '/^hostname/!d' $cfgi | sed 's/;//'
			#
			# append the modnames to the hostname
			if [ "${hostname_mods}" = "" ]; then
				hostname_mods=" Vanilla"
			fi

			fn_debugMessage "$FUNCNAME: hostname_mods $hostname_mods" "" "$RED"

			serverName=server$1[serverName]
			headlessClient=server$1[headlessClient]
			serverPort=server$1[port]
			serverPassword=server$1[serverPassword]
			adminPassword=server$1[adminPassword]
			adminSteamID=server$1[admins]
			serverMission=server$1[mission]

			hostname=${!serverName}$hostname_mods
			fn_debugMessage "$FUNCNAME: $hostname" "" "$RED"
			#
			# change hostname in file

			#echo "${serverArray[serverPassword]}"
			sed -i "/^hostname/c\hostname =\"$hostname\"\;" $cfgi
			sed -i "/^password =/c\password =\"${!serverPassword}\"\;" $cfgi
			sed -i "/^passwordAdmin =/c\passwordAdmin =\"${!adminPassword}\"\;" $cfgi

			arrayAdmins=()
			adminString=""

			for i in ${!adminSteamID}; do
				arrayAdmins+=($i)
			done

			echo "ADMINS: ${arrayAdmins[@]}"

			fn_debugMessage "$FUNCNAME: arrayAdmins ${arrayAdmins[@]}" "" "$RED"

			arrayCount=1 

			for admin in ${arrayAdmins[@]}; do
				if [[ $arrayCount -eq ${#arrayAdmins[@]} ]]; then
					adminString+=" \"$admin\""
				else
					adminString+=" \"$admin\","
				fi

				((arrayCount++))
			done
			
			sed -i "/^admins\[\] =/c\admins\[\] = \{$adminString \}\;" $cfgi
			sed -i "/template =/c\template = ${!serverMission}\;" $cfgi
		fi
	fi
	fn_debugMessage "$FUNCNAME: end" ""
}