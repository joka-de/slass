#
# SLASS - a3filepermissions
# 
# Author: seelenlos
# 
# Description:
# resets file permissons for the master instance
# 
# Parameter(s):
# Message <String>
# 
# Return Value:
# None <Any>
#
fn_printMessage "Resetting the file permissions in a3master ..."
find -L ${basepath}/a3/a3master -type d -exec chmod 775 {} \;
find -L ${basepath}/a3/a3master -type f -exec chmod 664 {} \;
chmod 774 ${basepath}/a3/a3master/arma3server
find ${basepath}/a3/a3master -iname '*.so' -exec chmod 775 {} \;
fn_printMessage " - DONE"