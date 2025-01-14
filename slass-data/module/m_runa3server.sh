#
# SLASS - m_runa3server
#
# Author: joka
#
# Description:
# laucher / manager for server instance {i}
#
# Parameter(s): { start | stop | restart | status | log } {i}
# Message <String>
#
# Return Value:
# None <Any>
#
case "$1" in
	start)
		# execute pre-start modules
		source $basepath/slass-data/module/m_mka3filestructure.sh $2
		source $basepath/slass-data/module/m_keylinker.sh $2
		source $basepath/slass-data/module/m_mkstartupconfig.sh $2

		# starting the servers
		source <(sed '/^nhc/!d' $sourcescfg)

		for index in $(seq 1 $(( $nhc + 1 ))); do
			fn_printMessage "m_runa3server: Starting process $index of server instance ${2}" "" "debug"
			fn_printMessage "m_runa3server: /bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${2}/startparameters_$index.scfg" "" "debug"
			/bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${2}/startparameters_$index.scfg
		done
	;;

	stop)
		# stopping the servers
		source <(sed '/^nhc/!d' ${basepath}/config/a3srv${2}.scfg)

		for index in $(seq 1 $(( $nhc + 1 ))); do
			fn_printMessage "m_runa3server: Stopping process $index of server instance ${2}" "" "debug"
			fn_printMessage "m_runa3server: /bin/bash $basepath/slass-data/p_a3server.sh stop $basepath/a3/a3srv${2}/startparameters_$index.scfg" "" "debug"
			/bin/bash $basepath/slass-data/p_a3server.sh stop $basepath/a3/a3srv${2}/startparameters_$index.scfg
		done
	;;

	restart)
	;;

	status)
		/bin/bash $basepath/slass-data/p_a3server.sh $1 $basepath/a3/a3srv${2}/startparameters_1.scfg
	;;

	log)
		/bin/bash $basepath/slass-data/p_a3server.sh $1 $basepath/a3/a3srv${2}/startparameters_1.scfg
	;;

	*)
		fn_printMessage "m_runa3server: wrong argument 1" "" "debug"
		fn_printMessage "m_runa3server: expected arguments ( start | stop | restart | status | log )" "" "debug"
		exit 1
	;;
esac