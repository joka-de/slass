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
declare -a allFunction

for file in $(find $basepath/slass-data/function/ -name 'fn_*.sh' -print); do
	allFunction=(${allFunction[@]} "$file")
	source $file
done

debug=$(fn_getJSONData "" "global.slass.debug" "-r")

if [[ "$debug" == "y" ]] && [[ "$1" -eq 1 ]]; then
	for file in "${allFunction[@]}"; do
		status=[Active]
		statusColor=$(tput setaf 2)

		if [[ "$file" == *"deprecated"* ]]; then
			status=[Deprecated]
			statusColor=$(tput setaf 3)
		fi

			fn_printMessage "loaded $file $statusColor$status$(tput sgr0)" "" "debug"
	done
fi