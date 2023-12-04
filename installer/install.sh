#!/bin/bash

# set this to "y" to avoid deletion of downloaded data (arma3 and steamcmd)
debug="y"

installerPath=$(dirname "$(readlink -f "$0")")
installPath="$(dirname "$installerPath")"
. $installerPath/functions/functionlist.sh
. $installerPath/install.cfg

debugMessage "Debug mode is ON" "-" "RED"
debugMessage "Path to Installer: $installerPath" " " "RED"
debugMessage "Path to install: $installPath" " " "RED"

printCentered "-" "-"
printCentered "-" "-"
printCentered "This will install SLASS including SteamCMD and startup / update scripts"
printCentered "-" "-"
printCentered "-" "-"
printCentered "Install Path: $installPath" 
printCentered "Admin-User: $userAdmin"
printCentered "Arma 3 Server executed by: $userLaunch"
printCentered "User Group: $groupServer"
printCentered ""
printCentered "Modify ./install.cfg to change the above."
printCentered "The script will OVERWRITE existing folders in the installation directory,"
printCentered "and you will be asked for the 'sudo' password by the script."
printCentered ""

read -p "Do you want to continue? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# scripted user management
printCentered "Do you want the users named above to be created?"
printCentered "!" "!"
printCentered "WARNING, if they already exist, they will be DELETED, including their home folders!"
printCentered "!" "!"
printCentered ""

read -p "Create Users? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

deleteAndCreateUser

# build basic folder structure
sudo chown ${userAdmin}:${groupServer} $installPath
sudo -u $userAdmin chmod 775 $installPath

if [[ $debug == "y"  ]]; then
		list=("scripts" "a3master" "steamcmd" "functions")		
	else		
		list=("scripts" "a3master" "steamcmd" "functions")
fi

for folder in "${list[@]}"; do
	if [[ -d ${installPath}/${folder} ]]; then
		debugMessage "Delete Folder : $folder" " " "RED"
		sudo -u $userAdmin rm -rf $installPath/$folder
	fi
		debugMessage "Create Folder : $folder" " " "RED"
		sudo -u $userAdmin mkdir $installPath/$folder --mode=775
done

# debug lines to clear a3master, but not downloaded content
if [[ $debug == "y"  ]]; then
	sudo -u $userAdmin rm -rf ${installPath}/a3master/_mods
	sudo -u $userAdmin rm -rf ${installPath}/a3master/cfg
	sudo -u $userAdmin rm -rf ${installPath}/a3master/log
	sudo -u $userAdmin rm -rf ${installPath}/a3master/userconfig/
fi

#sudo -u $userAdmin mkdir ${installPath}/scripts/service --mode=754
sudo -u $userAdmin mkdir ${installPath}/a3master/_mods --mode=775
sudo -u $userAdmin mkdir ${installPath}/a3master/cfg --mode=775
sudo -u $userAdmin mkdir ${installPath}/a3master/log --mode=775
#sudo -u $userAdmin mkdir ${installPath}/scripts/logs --mode=775
#sudo -u $userAdmin mkdir ${installPath}/scripts/tmp --mode=775
sudo -u $userAdmin mkdir ${installPath}/a3master/userconfig/ --mode=775

# copy files
: '
sudo -u $userAdmin cp ${installerPath}/rsc/servervars.cfg ${installPath}/scripts/service/
sudo -u $userAdmin chmod 644 ${installPath}/scripts/service/servervars.cfg
sudo -u $userAdmin cp ${installerPath}/rsc/modlist.inp ${installPath}/scripts/
sudo -u $userAdmin chmod 664 ${installPath}/scripts/modlist.inp
sudo -u $userAdmin cp ${installerPath}/rsc/a3srvi.sh ${installPath}/scripts/service/
sudo -u $userAdmin chmod 754 ${installPath}/scripts/service/a3srvi.sh
sudo -u $userAdmin cp ${installerPath}/rsc/prepserv.sh ${installPath}/scripts/service/
sudo -u $userAdmin chmod 754 ${installPath}/scripts/service/prepserv.sh
sudo -u $userAdmin cp ${installerPath}/rsc/a3common.cfg ${installPath}/a3master/cfg/
sudo -u $userAdmin chmod 664 ${installPath}/a3master/cfg/a3common.cfg
sudo -u $userAdmin cp ${installerPath}/rsc/basic.cfg ${installPath}/a3master/cfg/
sudo -u $userAdmin chmod 664 ${installPath}/a3master/cfg/basic.cfg
'

# build Arma3Profile
if [[ -d "/home/"${userLaunch}'/.local/share/Arma 3 - Other Profiles/'"${groupServer}" ]]; then
        sudo -u $userLaunch rm -rf /home/${userLaunch}"/.local/share/Arma 3 - Other Profiles/"${groupServer}
fi
sudo chmod 755 /home/${userLaunch}
sudo -u $userLaunch mkdir -p /home/${userLaunch}"/.local/share/Arma 3 - Other Profiles/"${groupServer} --mode=775
sudo -u $userLaunch cp ${installerPath}/rsc/profile.Arma3Profile /home/${userLaunch}"/.local/share/Arma 3 - Other Profiles/"${groupServer}/${groupServer}.Arma3Profile
sudo -u $userLaunch chmod 464 /home/${userLaunch}'/.local/share/Arma 3 - Other Profiles/'${groupServer}/*.Arma3Profile

# install steamcmd
if [[ ! -f "${installPath}/steamcmd/steamcmd.sh" ]]; then
	debugMessage "Download and install Steam" " " "RED"
	sudo apt install lib32gcc-s1 lib32stdc++6 rename
	cd $installPath/steamcmd
	sudo -u $userAdmin wget -nv http://media.steampowered.com/installer/steamcmd_linux.tar.gz
	sudo -u $userAdmin tar -xvzf steamcmd_linux.tar.gz
	sudo -iu $userAdmin ${installPath}/steamcmd/steamcmd.sh +runscript ${installerPath}/rsc/update.steam
	sudo -u $userAdmin rm -f ${installPath}/steamcmd/steamcmd_linux.tar.gz
	printCentered "SteamCMD was installed and is up to date!" "-"
fi

# set file permissions of ~/Steam folder
sudo -u $userAdmin find -L /home/${userAdmin}/Steam -type d -exec chmod 775 {} \;
sudo -u $userAdmin find -L /home/${userAdmin}/Steam -type f -exec chmod 664 {} \;

# build arma 3 master install script
sudo -u $userAdmin touch $installPath/scripts/arma3master.steam
sudo -u $userAdmin chmod 775 $installPath/scripts/arma3master.steam

sudo -u $userAdmin echo "@ShutdownOnFailedCommand 1" >> $installPath/scripts/arma3master.steam
sudo -u $userAdmin echo "@NoPromptForPassword 1" >> $installPath/scripts/arma3master.steam
sudo -u $userAdmin echo "force_install_dir $installPath/a3master" >> $installPath/scripts/arma3master.steam
sudo -u $userAdmin echo "login anonymous" >> $installPath/scripts/arma3master.steam
sudo -u $userAdmin echo "app_update 233780 validate" >> $installPath/scripts/arma3master.steam
sudo -u $userAdmin echo "quit" >> $installPath/scripts/arma3master.steam

read -p "Install ARMA 3 Server? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

sudo -u $userAdmin $installPath/steamcmd/steamcmd.sh +runscript $installPath/scripts/arma3master.steam