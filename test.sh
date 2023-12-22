#!/bin/bash
#
# SLASS - testscipt
# 
# Author: seelenlos
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
source $basepath/slass-data/module/m_fnloader.sh
#
serverid=1
debug=y
source $basepath/slass-data/module/m_keylinker.sh

