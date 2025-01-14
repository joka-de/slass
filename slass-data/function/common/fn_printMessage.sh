#
# SLASS - fn_printMessage
#
# Author: PhilipJFry
#
# Description:
# Print a message in givin color with givin filler, centered or left allign
#
# Parameter(s):
# 1: Message <String>
# 2: Filler <String>
# 3: Type of Message (debug, warning, error) <String>
#
# Return Value:
# None <Any>
#
# Example:
# fn_printMessage "Hello" - message centered
# fn_printMessage "Hello" "" - message left allign
# fn_printMessage "Hello" " " - message centered without filler
# fn_printMessage "Hello" "-" "error" - message centered, error marker and filler "-" left and right from the message
#
fn_printMessage () {
	fn_getFunctionStatus $FUNCNAME

	[[ $# == 0 ]] && return 1

	if [[ "$debug" == "n" && "$3" == "debug" ]]; then
		return 0
	fi

	local textColor=$(tput sgr0)
	local slassTag="[SLASS]"
	local messageType=""

	case $3 in
		warning)
			#Yellow
			textColor=$(tput setaf 3)
			messageType="[Warning]: "
		;;

		error)
			#Red
			textColor=$(tput setaf 1)
			messageType="[Error]: "
		;;

		debug)
			#Magenta
			textColor=$(tput setaf 5)
			messageType="[Debug]: "
		;;

		*)
			#Normal
			textColor=$(tput sgr0)
		;;
	esac

	GREEN=$(tput setaf 2)
	NC=$(tput sgr0)

	local tagAndMessage=$1

	if [[ -z $messageType ]]; then
		slassTag+=": "
	fi

	if [[ $# == 3 || $# == 2 ]]; then
		if [[ $1 != $2 ]]; then
			tagAndMessage=$slassTag$1
		else
			unset slassTag
		fi
	fi

	if [[ $# == 1 ]]; then
		if [[ ${#1} -le 1 ]]; then
			unset slassTag
		fi
	fi

	declare -i TERM_COLS="$(tput cols)"
	declare -i str_len="${#tagAndMessage}"

	[[ $str_len -ge $TERM_COLS ]] && {
	  echo "$tagAndMessage";
	  return 0;
	}

	declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"

	[[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "

	filler=""

	for (( i = 0; i < filler_len; i++ )); do
		filler="${filler}${ch}"
	done

	if [[ -z "$slassTag" ]]; then
    	if [[ $# == 3 ]]; then
			printf "%s${textColor}%s${NC}%s" "$filler" "$1" "$filler"
		else
			printf "%s%s%s" "$filler" "$1" "$filler"
	   	fi
	else
		if [[ $# == 3 ]]; then
			printf "%s${GREEN}%s${NC}${textColor}%s${NC}%s%s" "$filler" "$slassTag" "$messageType" "$1" "$filler"
		else
			printf "%s${GREEN}%s${NC}%s%s" "$filler" "$slassTag" "$1" "$filler"
	   	fi
	fi

	[[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
	printf "\n"

	return 0
}
