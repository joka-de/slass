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
		counter=0

		while read line; do		
	        if [[ $line =~ ^"["(.+)"]"$ ]]; then
	        	((counter++))
		        arrname=${BASH_REMATCH[1]}		        
		    	declare -A $arrname
		    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then 
		        declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"	       
		    fi	  	
		done < $basepath/config/server.scfg
		
		serverCount=$(expr $counter - 1)

		if [[ $serverCount -ge $1 ]]; then
			declare -n serverArrayGlobal="global"

			i=$1
			
			cfgi="${basepath}/a3/a3master/cfg/a3srv${1}.cfg"
			fn_debugMessage "$FUNCNAME: cfg file $cfgi" ""
			
			declare -n serverArray="server${1}"

			if [[ -f $cfgi ]]; then
				rm $cfgi
			fi

			if [[ -f "${basepath}/a3/a3master/cfg/basic.cfg" ]]; then
				rm "${basepath}/a3/a3master/cfg/basic.cfg"
			fi

			cp "${basepath}/config/a3srv${1}.cfg" $cfgi
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
			sed -i 's/ = /=/g' $cfgi
			#
			# extract hostname from source
			source <(sed '/^hostname/!d' $cfgi | sed 's/;//')
			#sed '/^hostname/!d' $cfgi | sed 's/;//'
			#
			# append the modnames to the hostname
			if [ "${hostname_mods}" = "" ]; then
				hostname_mods=${hostname_mods}" Vanilla"
			fi
			hostname="${hostname}${hostname_mods}"
			fn_debugMessage "$FUNCNAME: hostname $hostname"
			#
			# change hostname in file
			sed -i "/^hostname/c\hostname=\"$hostname\"" $cfgi
		fi
	fi
	fn_debugMessage "$FUNCNAME: end" ""
}