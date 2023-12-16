fn_createServer () {
	fn_debugMessage "fn_createServer: start" ""
		
	while read line; do
	    if [[ $line =~ ^"["(.+)"]"$ ]]; then
	    	arrname=${BASH_REMATCH[1]}
	        fn_debugMessage "Array: $arrname"
	    elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
	    	keyvalue=${BASH_REMATCH[1]}
	    	keyvaluecontent="${BASH_REMATCH[2]}"
	
	    	fn_debugMessage "key: $keyvalue"
	    	fn_debugMessage "content: $keyvaluecontent"
	
			declare ${arrname}[${keyvalue}]="${keyvaluecontent}"
	    fi
	done < /srv/slass/server.cfg
	
	echo ${server1[servername]}
	echo ${server1[mission]}
	 
	echo ${server2[servername]}
	echo ${server2[mission]}
 
	fn_debugMessage "fn_createServer: end" ""
}
