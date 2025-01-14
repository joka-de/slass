#
# SLASS - m_install
#
# Author: joka
#
# Description:
# installer module for steam and arma3
#
# Parameter(s):
# 1. option { start | stop | restart | status | log } <string>
# 2. server id {i} <integer>
#
# Return Value:
# None <Any>
#

goinst="n"
fn_printMessage "
---------------------------------------------
Installing steamcmd into:
$basepath

Do you want to continue? (y/n)" ""

read goinst
if [ $goinst != "y" ]; then
	exit 0
fi

# install steamcmd
fn_installsteamcmd