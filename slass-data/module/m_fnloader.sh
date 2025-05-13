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

validateJSON=$(jq . $basepath/config/server.json 1> /dev/null 2>&1 ; echo $?)

if [[ "$validateJSON" == "0" ]]; then 
	fn_printMessage "spell check $basepath/config/server.json: valid" ""
else
	fn_printMessage "spell check $basepath/config/server.json: invalid" "" "error"
	exit 1
fi

debug=$(fn_getJSONData "" ".global.slass.debug" "-r")

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