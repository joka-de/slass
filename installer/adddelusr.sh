#del users
sudo deluser --remove-home $useradm
sudo deluser --remove-home $userlnch
sudo groupdel $grpserver

#mkusers
sudo addgroup $grpserver
sudo adduser $useradm --gecos "" --ingroup $grpserver
sudo usermod -aG sudo $useradm
sudo adduser $userlnch --gecos "" --ingroup $grpserver --disabled-password --shell /bin/false
