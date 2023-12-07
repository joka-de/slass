fn_printMessage () {
     [[ $# == 0 ]] && return 1    

	local tagAndMessage=$1
	local slassTag="SLASS: "

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

     if [[ -z $slassTag ]]; then
     	if [[ $# == 3 ]]; then		
			printf "%s${3}%s${NC}%s" "$filler" "$1" "$filler"		
		else
			printf "%s%s%s" "$filler" "$1" "$filler"
	     fi
	else
		if [[ $# == 3 ]]; then		
			printf "%s${YELLOW}%s${NC}${3}%s${NC}%s" "$filler" "$slassTag" "$1" "$filler"		
		else
			printf "%s${YELLOW}%s${NC}%s%s" "$filler" "$slassTag" "$1" "$filler"
	     fi
	fi

     [[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "%s" "${ch}"
     printf "\n"

     return 0
}