#
# SLASS - mka3filestructure
# 
# Author: joka
# 
# Description:
# resets file permissons for the server instance {i}
# 
# Parameter(s): {i}
# Message <String>
# 
# Return Value:
# None <Any>
#
fn_printMessage "Building folder structure for  server ${serverid}"
if [ -d "${basepath}/a3/a3srv${serverid}" ]; then
		rm -rf $basepath/a3/a3srv${serverid}
fi
mkdir $basepath/a3/a3srv${serverid} --mode=775
ln -s ${a3instdir}/a3/a3master/* $basepath/a3/a3srv${serverid}/
rm -f $basepath/a3/a3srv${serverid}/keys
mkdir $basepath/a3/a3srv${serverid}/keys --mode=775
rm -f $basepath/a3/a3srv${serverid}/cfg
mkdir $basepath/a3/a3srv${serverid}/cfg --mode=775