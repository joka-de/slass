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
	# create alias for slass.sh ($userAdmin)
	file="/home/$userAdmin/.bash_aliases"

	if [[ ! -f $file ]]; then
			touch $file
	fi

	if ! grep -q 'alias for slass' "$file"; then
			fn_debugMessage "Eintrag für Alias nicht gefunden, Alias wird eingetragen" " "
			#echo "#alias for slass" >> $file
			#echo 'alias slass="$installDir/slass/slass.sh"' >> $file
	fi
}
