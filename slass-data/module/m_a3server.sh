#
# SLASS - m_a3server
# 
# Author: joka
# 
# Description:
# laucher / manager for server instance
# 
# Parameter(s):
# 1. option { start | stop | restart | status | log } <string>
# 2. server id {i} <integer>
# 
# Return Value:
# None <Any>
#
#
case "$1" in
	start)
		# execute pre-start modules
		source $basepath/slass-data/module/m_mka3filestructure.sh $2
		
		# create server configs
		fn_mkaconfig $2
		scfgi=$(fn_mksconfig $2)
		fn_a3filepermissions
		
		source $basepath/slass-data/module/m_keylinker.sh $2
		source $basepath/slass-data/module/m_mkstartupconfig.sh $2
		
		# starting the servers
		source <(sed '/^nhc/!d' $scfgi)
		
		for index in $(seq 1 $(( $nhc + 1 ))); do
			fn_printMessage "m_a3server: Starting process $index of server instance ${2}" "" "debug"
			fn_printMessage "m_a3server: /bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${2}/startparameters_$index.scfg" "" "debug"
			/bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${2}/startparameters_$index.scfg
		done
	;;

	stop)
		# stopping the servers
		if [ -e "${basepath}/a3/a3master/cfg/a3srv${2}.scfg" ]; then
			source <(sed '/^nhc/!d' ${basepath}/a3/a3master/cfg/a3srv${2}.scfg)
			fn_printMessage "m_a3server: loaded scfg for server instance ${2}" "" "debug"
			
			for index in $(seq 1 $(( $nhc + 1 ))); do
				fn_printMessage "m_a3server: Stopping process $index of server instance ${2}" "" "debug"
				fn_printMessage "m_a3server: /bin/bash $basepath/slass-data/p_a3server.sh stop $basepath/a3/a3srv${2}/startparameters_$index.scfg" "" "debug"
				/bin/bash $basepath/slass-data/p_a3server.sh stop $basepath/a3/a3srv${2}/startparameters_$index.scfg
			done
		else
			fn_printMessage "m_a3server: scfg for server instance ${2} not found, omiting to stop the prozess" "" "warning"
		fi
		
		# remove server dir
		fn_rmserverdir "${basepath}/a3/a3srv${2}"
	;;
	
	restart)
		$0 stop ${2}
		sleep 5s
		$0 start ${2}
	;;
				
	status)
		/bin/bash $basepath/slass-data/p_a3server.sh status $basepath/a3/a3srv${2}/startparameters_1.scfg
	;;
		
	log)
		/bin/bash $basepath/slass-data/p_a3server.sh log $basepath/a3/a3srv${2}/startparameters_1.scfg
	;;

	*)
		fn_printMessage "m_a3server: wrong argument 1" "" "debug"
		fn_printMessage "m_a3server: expected arguments ( start | stop | restart | status | log )" "" "debug"
		exit 1
	;;
esac