fn_createServer () {
	fn_debugMessage "fn_createServer: start" ""	

	while read line; do
	    if [[ $line =~ [^[:space:]] ]]; then	
		    if [[ $line =~ ^"["(.+)"]"$ ]]; then 
		        arrname=${BASH_REMATCH[1]}
		        declare -A $arrname
		    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then 
		        declare ${arrname}[${BASH_REMATCH[1]}]="${BASH_REMATCH[2]}"
		    fi
		else
			echo ${arrname[serverName]}
			echo ${arrname[serverPassword]}
		fi
	done < $installPath/config/server.cfg
	 
	fn_debugMessage "fn_createServer: end" ""
}
