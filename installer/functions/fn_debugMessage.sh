fn_debugMessage () {
	# displays every argument
	if [[ $# != 0 && $debug == "y" ]]; then
			case $# in
				1)
					fn_printMessage "$1" "" "$RED"
				;;
				2)
					fn_printMessage "$1" "$2" "$RED"
				;;
				3)
					fn_printMessage "$1" "$2" "$RED"
				;;
			esac
	fi
}