fn_mkaconfig () {
	fn_debugMessage "$FUNCNAME: start" ""	

	if [[ $# -eq 0 ]]; then 
		fn_printMessage "$FUNCNAME: Servernumber is $#" ""
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
		done < $installPath/config/server.scfg
		
		serverCount=$(expr $counter - 1)

		if [[ $serverCount -ge $1 ]]; then
			declare -n serverArrayGlobal="global"

			i=$1
				
			declare -n serverArray="server${i}"

			if [[ -f "$installPath/config/a3srv${i}.scfg" ]]; then
				rm "$installPath/config/a3srv${i}.scfg"
			fi

			if [[ -f "$installPath/a3/a3master/cfg/a3srv${i}.cfg" ]]; then
				rm "$installPath/a3/a3master/cfg/a3srv${i}.cfg"
			fi

			touch "$installPath/config/a3srv${i}.scfg"
			cp "$installPath/slass-data/rsc/a3master.cfg" "$installPath/a3/a3master/cfg/a3srv${i}.cfg"
			
			echo "nhc=${serverArray[headlessClient]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "basepath=$installPath" >> "$installPath/config/a3srv${i}.scfg"
			echo "ip=${serverArrayGlobal[ip]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "port=${serverArray[port]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "otherparams='${serverArrayGlobal[otherparams]}'" >> "$installPath/config/a3srv${i}.scfg"
			echo "logfilelifetime=${serverArrayGlobal[logfilelifetime]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "hostname=${serverArray[serverName]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "useradm=${serverArrayGlobal[useradm]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "username=${serverArrayGlobal[username]}" >> "$installPath/config/a3srv${i}.scfg"
			echo "profile=${serverArrayGlobal[profile]}" >> "$installPath/config/a3srv${i}.scfg"		
		fi
	fi
	fn_debugMessage "$FUNCNAME: end" ""
}
