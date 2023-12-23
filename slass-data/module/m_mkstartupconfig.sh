#
# SLASS - mkstartupconfig
# 
# Author: seelenlos
# 
# Description:
# creates the startup config startparameters_{ j }.scfg for server instance { i }
# 
# Parameter(s): {i}
# Message <String>
# 
# Return Value:
# None <Any>
#
# read data
scfg="${basepath}/config/a3srv${1}.scfg"
if [ -e $scfg ]; then
	source $scfg
	cat $scfg >> $filecont
else
	echo "SLASS:    File not found: $scfg"
	exit 1
fi
#
# make modlist
mods=""
servermods=""
hostname_mods=""
#
while read line; do
	appname=$(echo $line | awk '{ printf "%s", $1 }')
	applistname=$(echo $line | awk '{ printf "%s", $2 }')
	apptype=$(echo $line | awk '{ printf "%s", $4 }')
	appkey=$(echo $line | awk -v var=$(( $1 + 4 )) '{ printf "%s", $var }' )
	#
	if [[ -z "$appkey" ]]; then
		fn_printMessage "No modlist entry found for server ${1}, consider extending modlist"
		appkey=$(echo $line | awk -v var=$(( 5 )) '{ printf "%s", $var }' )
		fn_printMessage "... defaulting to entry for server 1 = ${appkey}"
	fi
	#
	fn_debugMessage "appname = ${appname} | applistname = ${applistname} | apptype = ${apptype} | appkey = ${appkey}"
	#
	if [ "${apptype}" = "mod" ] && [ "${appkey}" = "1" ]; then
		case "$appname" in
			gm|vn|csla|ws)
				mods=${mods}${appname}";"
			;;
			*)
				mods=${mods}"_mods/@"${appname}";"
			esac
	fi
	#
	
	if [ "${apptype}" = "smod" ] && [ "${appkey}" = "1" ]; then
			servermods=${servermods}"_mods/@"${appname}";"
	fi
	#
	if [ "${applistname}" != "xx" ] && [ "${appkey}" = "1" ]; then
		if [ "${hostname_mods}" = "" ]; then
		hostname_mods=${hostname_mods}" ${applistname}"
		else
		hostname_mods=${hostname_mods}", ${applistname}"
		fi
	fi
done < ${basepath}/config/modlist.inp


# create the startparameter files for each instance
imax=$(($nhc+1))
for index in $(seq 1 $imax);
do
	cat $scfg > "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nmods=$mods\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nservermods=$servermods\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
done