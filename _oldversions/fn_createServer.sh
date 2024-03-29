fn_createServer () {
	fn_debugMessage "fn_createServer: start" ""	

	counter=0

	while read line; do		
        if [[ $line =~ ^"["(.+)"]"$ ]]; then
        	((counter++))
	        arrname=${BASH_REMATCH[1]}		        
	    	declare -A $arrname
	    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then 
	        declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"	       
	    fi	  	
	done < $installPath/config/server.cfg
	
	for (( i=1; i<=$counter; i++ )); do  
		declare -n serverArray="server${i}"
		echo ${serverArray[serverName]}
		echo ${serverArray[serverPassword]}
		echo ${serverArray[adminPassword]}
		echo ${serverArray[mission]}
	done

	fn_debugMessage "fn_createServer: end" ""
}
