apt-get upgrade && apt-get update
##create private network 
apt install net-tools
sudo ifconfig eth0 192.168.1.21 netmask 255.255.255.0
sudo route add default gw 192.168.1.1 eth0
    #test
    res=$(ping -c 1 192.168.1.20 &> /dev/null && echo 0 || echo 1 )

##init connexion with server



apt-get instal rsync

chmod 444 $File
rsync -avzP $File server@server:~/home/server/cloud
##-a (–archive) will also copy the permissions, modification times, and any other date.
##-z (–compress)
##-P Progress bar

