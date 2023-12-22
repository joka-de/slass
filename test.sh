#!/bin/bash
#
# SLASS - testscipt
# 
# Author: joka
# 
# Description:
# does some shit
# 
# Parameter(s): some
# Message <String>
# 
# Return Value:
# None <Any>
#
#----------------
basepath=$(dirname "$(readlink -f "$0")")
#source $basepath/slass-data/module/m_fnloader.sh
#
serverid=1
#debug=y
#source $basepath/slass-data/module/m_keylinker.sh

/bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${serverid}/startparameters_1.scfg
sleep 5
#/bin/bash $basepath/slass-data/p_a3server.sh start $basepath/a3/a3srv${serverid}/startparameters_1.scfg