# SLASS - fnloader
# 
# Author: seelenlos
# 
# Description:
# loads functions
# 
# Parameter(s):
# Message <String>
# 
# Return Value:
# None <Any>
#
for file in $(find $basepath/slass-data/function/ -name 'fn_*.sh' -print)
do
	source $file
	echo "SLASS: loaded $file"
done
