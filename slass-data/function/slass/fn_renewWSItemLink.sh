#
# SLASS - fn_renewWSItemLink
#
# Author: PhilipJFry
#
# Description:
# Search for dependencies, unknown workshop items and update server.json
#
# Parameter(s):
# 1) Workshop Item ID <String>
#
# Return Value:
# None <Any>
#
fn_renewWSItemLink() {
	fn_getFunctionStatus $FUNCNAME

	local rwsItemID
	rwsItemID=$1

	local rwsItemName
	rwsItemName=$2
	
	# all mods where the name changed will be linked new
	local rwsItemBikeyPath
	rwsItemBikeyPath=$(find $basepath/steamapps/workshop/content/107410/$rwsItemID/keys/ -type f -name *.bikey)

	local rwsItemBikey
	rwsItemBikey=$(basename $rwsItemBikeyPath)

	local rwsItemBikeyLinkPath
	rwsItemBikeyLinkPath=$(find -L $basepath/a3/a3master/_mods/ -type f -name $rwsItemBikey)

	local rwsItemLinkPath
	rwsItemLinkPath=$(echo $rwsItemBikeyLinkPath | cut -d'/' -f-8)
	
	find $rwsItemLinkPath -type l -delete							

	ln -s $basepath/steamapps/workshop/content/107410/$rwsItemID $basepath/a3/a3master/_mods/@$rwsItemName
}