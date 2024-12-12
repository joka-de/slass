#
# SLASS - fn_getJSONData
#
# Author: PhilipJFry / chucky
#
# Description:
# Get and return value from json file
#
# Parameter(s):
# Server ID <String>
# Key <String>
# jq Option <String>
# JSON File <String>
#
# Example(s):
# output=$(fn_getJSONData "1" "slass.port")
# output=$(fn_getJSONData "1" "slass.ip" "-r")
# output=$(fn_getJSONData "1" "slass.ip" "" "myServer.json")
# output=$(fn_getJSONData "" "global.slass.port")
# output=$(fn_getJSONData "1")
#
# Return Value:
# Any <String>
#
fn_getJSONData () {
    fn_getFunctionStatus $FUNCNAME

    local serverFile="${basepath}/config/serverSml.json"
                
    if [[ -n "$4" ]]; then
        serverFile="${basepath}/config/$4"
    fi

    local output=""
    local key=""
    local jqOption=""

    if [[ -n "$3" ]]; then
        jqOption="$3"
    fi

    if [[ -n "$1" ]]; then
        local re='^[0-9]+$'
        
        if [[ ! $1 =~ $re ]]; then 
            fn_printMessage "$FUNCNAME: wrong argument 1 (must be integer number)" "" "error"
            exit 1
        fi
        
        key+=".server${1}"

        if [[ -n "$2" ]]; then
            key+=".$2"

            output=$(jq ''"$key"'' $serverFile $jqOption)

            if [[ "$output" = "null" ]]; then
                key=".global.$2"
                output=$(jq ''"$key"'' $serverFile $jqOption)
            fi                        
        else
             output=$(jq ''"$key"'' $serverFile $jqOption)
        fi
    else
        if [[ -n "$2" ]]; then
            key+=".$2"

            output=$(jq ''"$key"'' $serverFile $jqOption)                                               
        else
            fn_printMessage "$FUNCNAME: argument 1 and 2 are missing (one of these are expected)" "" "error"
        fi
    fi      
    
    printf "$output\n"
 }
