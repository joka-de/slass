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
source $basepath/slass-data/module/m_mka3filestructure.sh $2
source $basepath/slass-data/module/m_keylinker.sh $2
source $basepath/slass-data/module/m_mkstartupconfig.sh $2
#preparations needed
#/bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${serverid}/startparameters_1.scfg
;;
#
#
stop)

;;
#
#
restart)

;;
#
#
status)
/bin/bash $basepath/slass-data/p_a3server.sh $1 $basepath/a3/a3srv${2}/startparameters_1.scfg
;;
##
log)
/bin/bash $basepath/slass-data/p_a3server.sh $1 $basepath/a3/a3srv${2}/startparameters_1.scfg
;;
*)
	fn_printMessage " wrong argument 1" ""
	fn_printMessage " expected arguments ( start | stop | restart | status | log )" ""
	exit 1
;;

esac