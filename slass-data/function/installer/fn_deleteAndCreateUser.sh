#
# SLASS - fn_deleteAndCreateUser
# 
# Author: PhilipJFry
# 
# Description:
# Delete and create givin user(s) defined in install.cfg
# 
# Parameter(s):
# 1: Mode <String> - Mode: delete, create | Default: all
# 
# Return Value:
# None <Any>
#

fn_deleteAndCreateUser () {
	fn_getFunctionStatus $FUNCNAME

	local option
	option="all"

	if [[ -n $1 ]]; then
		option=$1
	fi

	fn_printMessage "$FUNCNAME: $option" "" "debug"

	# delete user
	if [[ $option == "delete" || $option == "all" ]]; then
		if [[ -d /home/${userAdmin} ]]; then
			fn_printMessage "$FUNCNAME: User $userAdmin wird gelöscht" "" "debug"
			sudo deluser --remove-home $userAdmin
		fi

		if [[ -d /home/${userLaunch} ]]; then
			fn_printMessage "$FUNCNAME: User $userLaunch wird gelöscht" "" "debug"
			sudo deluser --remove-home $userLaunch
		fi

		fn_printMessage "$FUNCNAME: Gruppe $groupServer wird gelöscht" "" "debug"
		sudo groupdel $groupServer
	fi

	# create user
	if [[ $option == "create" || $option == "all" ]]; then
		sudo addgroup $groupServer
		fn_printMessage "$FUNCNAME: User $userAdmin wird erstellt" "" "debug"
		sudo adduser $userAdmin --gecos "" --ingroup $groupServer
		sudo usermod -aG sudo $userAdmin
		fn_printMessage "$FUNCNAME: User $userLaunch wird erstellt" "" "debug"
		sudo adduser $userLaunch --gecos "" --ingroup $groupServer --disabled-password --shell /bin/false
	fi
}
