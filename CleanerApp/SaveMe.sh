
###################
#send to the server now
# set as parameter name of the commit = $commit

# rsync Options Les-Sources La-Destination
# ipSource = 192.168.1.10 = main
# sourc path = /home/main/cloud/"$commit - $today"
# ipDest = 192.168.1.20 = server
# dest path = /home/server/cloud/"$commit - $today"

DestPath='/home/server/cloud/"$commit - $today"'
mkdir "$DestPath"


