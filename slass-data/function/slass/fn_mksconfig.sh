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
		fn_readServerConfig

		if [[ $serverCount -ge $1 ]]; then
			i=$1
			scfgi="${basepath}/a3/a3master/cfg/a3srv${1}.scfg"
			fn_debugMessage "$FUNCNAME: scfg file $scfgi" ""
						
			if [[ -f $scfgi ]]; then
				rm $scfgi
			fi
			
			serverIP=global[ip]
			params=global[otherparams]
			logfilelifetime=global[logfilelifetime]

			serverName=server$1[serverName]
			headlessClient=server$1[headlessClient]
			serverPort=server$1[port]

			printf "nhc=${!headlessClient}" > $scfgi
			printf "\nbasepath=$basepath" >> $scfgi
			printf "\nip=${!serverIP}" >> $scfgi
			printf "\nport=${!serverPort}" >> $scfgi
			printf "\notherparams=\"${!params}\"" >> $scfgi
			printf "\nlogfilelifetime=${!logfilelifetime}" >> $scfgi
			
			printf "\nhostname=\"${!serverName}\"" >> $scfgi
			#printf "\nuseradm=${serverArrayGlobal[useradm]}" >> $scfgi
			#printf "\nuserlnch=${serverArrayGlobal[userlnch]}" >> $scfgi
			#printf "\nprofile=${serverArrayGlobal[profile]}" >> $scfgi
		fi
	fi
	fn_debugMessage "$FUNCNAME: end" ""
}