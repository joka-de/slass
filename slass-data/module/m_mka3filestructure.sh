#
# SLASS - mka3filestructure
# 
# Author: joka
# 
# Description:
# resets file permissons for the server instance {i}
# 
# Parameter(s): { i }
# Message <String>
# 
# Return Value:
# None <Any>
#
fn_printMessage "Building folder structure for server ${1}" ""
if [ -d "${basepath}/a3/a3srv${1}" ]; then
		fn_debugMessage "clearing existing instance of server server ${1}" ""
		rm -rf $basepath/a3/a3srv${1}
fi
mkdir $basepath/a3/a3srv${1} --mode=775
ln -s $basepath/a3/a3master/* $basepath/a3/a3srv${1}/
rm -f $basepath/a3/a3srv${1}/keys
mkdir $basepath/a3/a3srv${1}/keys --mode=775
#rm -f $basepath/a3/a3srv${1}/cfg
#mkdir $basepath/a3/a3srv${1}/cfg --mode=775