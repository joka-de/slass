#!/bin/bash

debug="y"

RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

installPath=$(dirname "$(readlink -f "$0")")
. $installPath/config/slass.cfg

for var in $installPath/slass-data/function/common/*.sh; do
    . "$var"
done

for var in $installPath/slass-data/function/slass/*.sh; do
    . "$var"
done

cp $installPath/slass-data/rsc/server.cfg $installPath/config/server.cfg

fn_debugMessage "Path of slass: $installPath" ""

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
	config)
		fn_debugMessage "Create Config" ""
		fn_mkaconfig $2
	;;
	*)
		fn_printMessage "Wrong option! Please use create, start, stop or restart"
	;;
esac
