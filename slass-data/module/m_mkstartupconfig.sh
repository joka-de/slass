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

loadedmods=$(fn_getJSONData "" ".global.slass.modtoload + .server${1}.slass.modtoload | .[]" "-r")

fn_getAppID "$loadedmods" "require" "$1"
loadedmods=$returnValue
unset returnValue

fn_printMessage "MODS: $mods" "" "debug"
fn_printMessage "SERVERMODS: $servermods" "" "debug"

fn_manageMod "startup" "$loadedmods" "" "modrepo"
fn_printMessage "MODS: $mods" "" "debug"
fn_printMessage "SERVERMODS: $servermods" "" "debug"

# extract port from source
source <(sed '/^port/!d' $scfgi)

# write the startparameter files for each instance
imax=$(($nhc+1))

for index in $(seq 1 $imax); do
	printf "\nserverid=$1\n" > "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
	printf "\nprocessid=$index\n" >> "${basepath}/a3/a3srv${1}/startparameters_${index}.scfg"
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