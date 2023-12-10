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
	local option
	option="all"

	if [[ -n $1 ]]; then
		option=$1
	fi

	# delete user
	if [[ $option != "create" ]]; then
			if [[ -d /home/${userAdmin} ]]; then
				fn_debugMessage "User $userAdmin wird gelöscht" ""
				sudo deluser --remove-home $userAdmin
			fi

			if [[ -d /home/${userLaunch} ]]; then
				fn_debugMessage "User $userLaunch wird gelöscht" ""
				sudo deluser --remove-home $userLaunch
			fi

			fn_debugMessage "Gruppe $groupServer wird gelöscht" ""
			sudo groupdel $groupServer
	fi

	# create user
	if [[ $option != "delete" ]]; then
			sudo addgroup $groupServer
			fn_debugMessage "User $userAdmin wird erstellt" ""
			sudo adduser $userAdmin --gecos "" --ingroup $groupServer
			sudo usermod -aG sudo $userAdmin
			fn_debugMessage "User $userLaunch wird erstellt" ""
			sudo adduser $userLaunch --gecos "" --ingroup $groupServer --disabled-password --shell /bin/false
	fi
}
