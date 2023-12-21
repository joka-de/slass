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

fn_printMessage "resetting the file permissions in a3master ..."
find -L $a3instdir/a3/a3master -type d -exec chmod 775 {} \;
find -L $a3instdir/a3/a3master -type f -exec chmod 664 {} \;
chmod 774 $a3instdir/a3/a3master/arma3server
find $a3instdir/a3/a3master -iname '*.so' -exec chmod 775 {} \;
echo $' - DONE\n'