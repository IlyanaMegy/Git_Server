#!/bin/bash
ssh-keygen -q -t rsa -N '' <<< ""$'\n'"y"
echo ""
touch your_ssh_public_key
cp  /c/Users/ily/.ssh/id_rsa.pub  your_ssh_public_key
echo ""
echo "------------------------------------------------"
echo "Here's your ssh public key."
echo "------------------------------------------------"
ls
cat your_ssh_public_key
echo "------------------------------------------------"
echo ""
echo "We will now send your public key to your VM server"
ssh user@192.168.30.2 "mkdir -p ~/.ssh"
scp your_ssh_public_key user@192.168.30.10:/home/user/.ssh/authorized_keys
echo "Done ! You can now close this program and continue the tuto..."
read