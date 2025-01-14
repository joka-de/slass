#
# SLASS - mkstartupconfig
#
# Author: joka
#
# Description:
# creates the startup config startparameters_{ j }.scfg for server instance { i }
#
# Parameter(s):
# 1. server id {i} <Integer>
# 2. scfgi path <String>
#
# Return Value:
# None <Any>
#

if [[ -f "$scfgi" ]]; then
	source $scfgi
else
	fn_printMessage "mk_startupconfig: File not found: $scfgi. Aborting." "" "error"
	exit 1
fi

# make modlist
mods=""
servermods=""
hostname_mods=""

loadedmods=$(fn_getJSONData "" "global.slass.modtoload + .server${1}.slass.modtoload | .[]" "-r")

for mod in $loadedmods; do
	appname=$mod
	apptype=$(fn_getJSONData "" "global.slass.modrepo.${appname}.apptype" "-r")
	appid=$(fn_getJSONData "" "global.slass.modrepo.${appname}.appid")
	inservername=$(fn_getJSONData "" "global.slass.modrepo.${appname}.inservername" "-r")

	fn_printMessage "mk_startupconfig: appname = ${appname} | appid = ${appid} | apptype = ${apptype} | inservername = ${inservername}" "" "debug"

	if [[ "${apptype}" = "mod" ]]; then
		case "$appname" in
			gm|vn|csla|ws|spe|rf|ef)
				mods=${mods}${appname}";"
			;;
			*)
				mods=${mods}"_mods/@"${appname}";"
			;;
		esac
	fi

	if [[ "${apptype}" = "smod" ]]; then
			servermods=${servermods}"_mods/@"${appname}";"
	fi

	if [[ "$inservername" != "null" ]] && [[ ! -z "$inservername" ]]; then
		if [ "${hostname_mods}" = "" ]; then
			hostname_mods=${hostname_mods}" ${inservername}"
		else
			hostname_mods=${hostname_mods}", ${inservername}"
		fi
	fi
done

# extract hostname from source
source <(sed '/^hostname/!d' $scfgi)

# extract port from source
source <(sed '/^port/!d' $scfgi)

# append the modnames to the hostname
if [ "${hostname_mods}" = "" ]; then
	hostname_mods=${hostname_mods}" Vanilla"
fi

hostname="${hostname}${hostname_mods}"
fn_printMessage "mkstartupconfig: hostname $hostname" "" "debug"

# write the startparameter files for each instance
imax=$(($nhc+1))

for index in $(seq 1 $imax); do
	printf "\nserverid=$1\n" > "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nprocessid=$index\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nhostname=\"$hostname\"\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	#printf "\nport=$(($port + (($index - 1 )*10)))\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nport=$port\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"

	if [ $index = "1" ]; then
		printf "\nishc=false\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	else
		printf "\nishc=true\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"

		if [[ "$password" != "null" ]] && [[ ! -z "$password" ]]; then
			otherparams+=" -password=$password"			
		fi
	fi

	# import source while omiting some lines
	cat $scfgi | sed '/^hostname/d' | sed '/^nhc/d' | sed '/^port/d' | sed '/^otherparams/d' >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nmods=\"$mods\"\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nservermods=\"$servermods\"\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\notherparams=\"$otherparams\"\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"

	#delete empty lines
	sed -i '/^[[:space:]]*$/d' ${basepath}/a3/a3srv${1}/startparameters_${index}.scfg
done