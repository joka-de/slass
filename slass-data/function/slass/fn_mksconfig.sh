#
# SLASS - fn_mksconfig
# 
# Author: Fry
# 
# Description:
# create scfg for server instance a3srv{i}
# 
# Parameter(s):
# 1. server id {i} <integer>
#
# Return Value:
# None <Any>
#
fn_mksconfig () {
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
			
			declare -n serverArray="server${1}"

			if [[ -f $scfgi ]]; then
				rm $scfgi
			fi
			
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