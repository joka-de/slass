#!/bin/bash

debug="y"

installPath=$(dirname "$(readlink -f "$0")")
. $installPath/slass.cfg

for var in $installPath/function/common/*.sh; do
    . "$var"
done

for var in $installPath/function/slass/*.sh; do
    . "$var"
done

case $1 in
	create)
		fn_debugMessage "Create Server" ""
		fn_createServer
	;;
	start)
		fn_debugMessage "Start Server" ""
		fn_startServer
	;;
	stop)
		fn_debugMessage "Stop Server" ""
		fn_stopServer
	;;
	restart)
		fn_debugMessage "Restart Server" ""
		fn_restartServer
	;;
	*)
		fn_printMessage "Wrong option! Please use create, start, stop or restart"
	;;
esac
