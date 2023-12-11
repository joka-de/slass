fn_createServer () {
	fn_debugMessage "fn_createServer: start" ""

	while read p; do
		if [[ $p != "" ]]; then
			echo $p
			. $p
		fi
	done < $installPath/server.cfg

	fn_debugMessage "$name" ""
	fn_debugMessage "$map" ""

	fn_debugMessage "fn_createServer: end" ""
}
