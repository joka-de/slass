debugMessage () {
	# displays every argument
	if [[ $# != 0 && $debug == "y" ]]; then
			#for var in "$@"
				#do
    					#printf "${RED}$var${NC}\n"
			#done
			case $# in
				1)
					printCentered "$1"
				;;
				2)
					printCentered "$1" "$2"
				;;
				3)
					printCentered "$1" "$2" "$3"
				;;
			esac
	fi
}

deleteAndCreateUser () {
	# delete user
	local option
	option="all"

	if [[ -n $1 ]]; then
		option=$1
	fi

	if [[ $option != "create" ]]; then
			if [[ -d /home/${userAdmin} ]]; then
				debugMessage "User $userAdmin wird gelöscht" " " "RED"
				sudo deluser --remove-home $userAdmin
			fi

			if [[ -d /home/${userLaunch} ]]; then
				debugMessage "User $userLaunch wird gelöscht" " " "RED"
				sudo deluser --remove-home $userLaunch
			fi

			debugMessage "Gruppe $groupServer wird gelöscht" " " "RED"
			sudo groupdel $groupServer
	fi

	# create user
	if [[ $option != "delete" ]]; then
			sudo addgroup $groupServer
			debugMessage "User $userAdmin wird erstellt" " " "RED"
			sudo adduser $userAdmin --gecos "" --ingroup $groupServer
			sudo usermod -aG sudo $userAdmin
			debugMessage "User $userLaunch wird erstellt" " " "RED"
			sudo adduser $userLaunch --gecos "" --ingroup $groupServer --disabled-password --shell /bin/false
	fi
}

createAlias () {
	# create alias for slass.sh ($userAdmin)
	file="/home/$userAdmin/.bash_aliases"

	if [[ ! -f $file ]]; then
			touch $file
	fi

	if ! grep -q 'alias for slass' "$file"; then
			debugMessage "Eintrag für Alias nicht gefunden, Alias wird eingetragen" " " "RED"
			#echo "#alias for slass" >> $file
			#echo 'alias slass="$installDir/slass/slass.sh"' >> $file
	fi
}

printCentered () {
     [[ $# == 0 ]] && return 1

     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
     [[ $str_len -ge $TERM_COLS ]] && {
          echo "$1";
          return 0;
     }

     declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
     [[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
     filler=""
     for (( i = 0; i < filler_len; i++ )); do
          filler="${filler}${ch}"
     done

     RED='\033[0;31m'
	NC='\033[0m' # No Color

     if [[ $# == "3" ]]; then
			case $3 in
				RED)
					printf "%s${RED}%s${NC}%s" "$filler" "$1" "$filler"
				;;
				*)
					printf "%s%s%s" "$filler" "$1" "$filler"
				;;
			esac     		
	    	else
     		printf "%s%s%s" "$filler" "$1" "$filler"
     fi

     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}