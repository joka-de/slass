#
# SLASS - fn_ceateAlias
#
# Author: PhilipJFry
#
# Description:
# Creates a alias for slass.sh
#
# Parameter(s):
# None <Any>
#
# Return Value:
# None <Any>
#

fn_createAlias () {
	fn_getFunctionStatus $FUNCNAME

	# create alias for slass.sh ($userAdmin)
	local file="/home/$userAdmin/.bash_aliases"

	if [[ ! -f $file ]]; then
			touch $file
	fi

	if ! grep -q 'alias for slass' "$file"; then
		fn_printMessage "$FUNCNAME: Eintrag für Alias nicht gefunden, Alias wird eingetragen" "" "debug"
		echo "#alias for slass" >> $file
		printf 'alias slass="%s/slass.sh"' $installPath >> $file
	else
		fn_printMessage "$FUNCNAME: Eintrag für alias bereits vorhanden" "" "debug"
	fi
}
