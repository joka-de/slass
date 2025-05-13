#
# SLASS - keylinker
#
# Author: seelenlos
#
# Description:
# creates creates symlinks to the appropiate keys for server instance { i }
#
# Parameter(s):
# 1. server id {i} <integer>
#
# Return Value:
# None <Any>
#
# a3 basegame key
ln -s ${basepath}/a3/a3master/keys/a3.bikey ${basepath}/a3/a3srv${1}/keys/

# mod keys
mods=$(fn_getJSONData "" ".global.slass.modtoload + .server${1}.slass.modtoload | .[]" "-r")

fn_getAppID "$mods" "require" "$1"
mods=$returnValue
unset returnValue

fn_manageMod "linkkey" "$mods" "$1" "modrepo"