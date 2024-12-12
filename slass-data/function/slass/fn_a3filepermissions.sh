#
# SLASS - fn_a3filepermissions
# 
# Author: seelenlos
# 
# Description:
# resets file permissons for the master instance
# 
# Parameter(s):
# None <Any>
# 
# Return Value:
# None <Any>
#
fn_a3filepermissions () {
	fn_getFunctionStatus $FUNCNAME
	fn_printMessage "Resetting the file permissions in a3master ..." ""
	find -L ${basepath}/a3/a3master -type d -exec chmod 775 {} \;
	find -L ${basepath}/a3/a3master -type f -exec chmod 664 {} \;
	chmod 774 ${basepath}/a3/a3master/arma3server
	chmod 774 ${basepath}/a3/a3master/arma3server_x64
	find ${basepath}/a3/a3master -iname '*.so' -exec chmod 775 {} \;
	chmod 774 ${basepath}/slass-data/p_a3server.sh
	fn_printMessage " - DONE" ""
}
