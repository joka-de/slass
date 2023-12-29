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
			scfgi="${basepath}/a3/a3master/cfg/a3srv${1}.scfg"
			fn_debugMessage "$FUNCNAME: scfg file $scfgi" ""
			
			cfgi="${basepath}/a3/a3master/cfg/a3srv${1}.cfg"
			fn_debugMessage "$FUNCNAME: cfg file $cfgi" ""
			
			declare -n serverArray="server${1}"

			if [[ -f $scfgi ]]; then
				rm $scfgi
			fi

			if [[ -f $cfgi ]]; then
				rm $cfgi
			fi

			if [[ -f "${basepath}/a3/a3master/cfg/basic.cfg" ]]; then
				rm "${basepath}/a3/a3master/cfg/basic.cfg"
			fi

			cp "${basepath}/config/a3master.cfg" $cfgi
			cp "${basepath}/config/basic.cfg" "${basepath}/a3/a3master/cfg/basic.cfg"
			
			printf "\nnhc=${serverArray[headlessClient]}" > $scfgi
			printf "\nbasepath=$basepath" >> $scfgi
			printf "\nip=${serverArrayGlobal[ip]}" >> $scfgi
			printf "\nport=${serverArray[port]}" >> $scfgi
			printf "\notherparams=\"${serverArrayGlobal[otherparams]}\"" >> $scfgi
			printf "\nlogfilelifetime=${serverArrayGlobal[logfilelifetime]}" >> $scfgi
			printf "\nhostname=\"${serverArray[serverName]}\"" >> $scfgi
			printf "\nuseradm=${serverArrayGlobal[useradm]}" >> $scfgi
			printf "\nuserlnch=${serverArrayGlobal[userlnch]}" >> $scfgi
			printf "\nprofile=${serverArrayGlobal[profile]}" >> $scfgi
		fi
	fi
	fn_debugMessage "$FUNCNAME: end" ""
}