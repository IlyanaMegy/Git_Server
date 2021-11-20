 Install your own Git server on a VM


Hi! Here's  a tuto to set up your server. Not really complicated, just follow the instructions step by step.

  - [1. Create the VM](#1-create-the-vm)
  - [2. Network settings](#2-network-settings)
  - [3. SSH-keygen](#3-ssh-keygen)
  - [4. Install git](#4-install-git)
  - [5. Unit test to make my code perfect](#5-unit-test-to-make-my-code-perfect)# 

## 1. Create the VM

---

For this tutorial I chose to use a CentOS7 iso, you can adapt the followed bash script if you prefer another Linux distribution.

Before we start I need to download some stuff, do not worry my friend i have a list just for you :)

-> First if you don't have it, download VirtualBox ! (Here's a pretty [usefull link](https://www.virtualbox.org/wiki/Downloads))

-> Ok now you need to get that CentOS iso file, i advise you to download  [this one](https://www.centos.org/download/), rename it centos.iso and copy/paste it to this current folder)

-> I assume you've done with the VirtualBox install so now let's configure a network interface so you can have you're very special ip adress on your VM:
-  OK go to the `File/Host Network Manager`  window and let's add a new network interface, wait a bit it may takes time...
- set a network ip 10.0.3.1/24


Nice, now we can start that VM's Setup, to make it quicker for you i've wrote a little bash script, run **create_CentOS_VM.sh**.
-> Just execute it and wait until the VM install is done. 

---
## 2. Network settings

At this point you must have noticed your VM infos, just also know that your login is **user** and password **root**, you'll be able to change it later...

If you're writing on a azerty keyboard you may need to config this on your CentOS machine.
To switch to AZERTY just type this commande :
localectl set-keymap fr

Little trick, you can type:
locqlectl set)key,qp fr

Also let's give to user all rights just like root have.

    su
    usermod -aG root user
then modify /etc/sudoers file and add this line under root's one:

    user	ALL=(ALL)	NOPASSWD: ALL

You can now stop your machine and go to the VM setting page on your VirtualBox interface.

Add the network interface we've created together :)

![helpings](https://cdn.discordapp.com/attachments/889061317321838627/905803252736622632/unknown.png)

Alright we can restart our VM.

Next we have to configure your static IP, create and then copy those lines into the `/etc/sysconfig/network-scripts/ifcfg-enp0s8` file.

```
sudo nano /etc/sysconfig/network-scripts/ifcfg-enp0s8
```
```
NAME=enp0s8
DEVICE=enp0s8
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.0.3.10
NETMASK=255.255.255.0
```
save and exit the file then use ,
```
sudo ifdown enp0s3
sudo ifup enp0s3
```
... to restart network service.

You're now able to see your static IP address by using the commande `ip a`.
So you are now able to connect to your local machine with SSH, you can share some files between the two machines and so will you !

## 3. Install git

Once that's done we can start the real set-up.
We will install git on both machines, so you can use the VM as a git server.

To install git on your local machine, if it's on a Windows' OS go download it on [this website](https://git-scm.com/download/win) and follow the installations instructions. 
If your machine is on Linux execute this command :

    apt-get install git

Then we will install it on your VM, follow those commands :
```
#install git
yum update
yum install git-core -y

#create git user with "root" as password
su -
sudo useradd git
echo  "root" | passwd --stdin git
usermod -aG wheel git

#create the saved-files-folder as git user and git init
su git
mkdir /home/git/clone

cd /home/git/clone && git init --bare
```

And we're done with the Setup !
Now each time you need to push some projects of yours on your server do 
init git on the current folder :

```
c:\Users\ily\Documents\ynov\mywork
λ git init
Initialized empty Git repository in C:/Users/ily/Documents/ynov/mywork/.git/
```
... add all your work to commit them :

    git add *
    git commit -m "updated work on 10/11/21"

and git git remote to your server before push.

    git remote add origin ssh://git@10.0.3.10:/home/git/clone
    git push origin master
And that's it.
Now let's try to create a check-in-before-commit program.
We will just ask git to execute our unit test just before it commits our code.

## 4. SSH-keygen

To simplify your interactions with your server, you better set-up a password-less ssh login. 
-> Execute those following lines in the terminal of your VM as git user;

```
ssh-keygen -t rsa -b 4096

touch /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys
chmod 700 /home/git/.ssh
```
Go to your host machine's terminal...

and type that ssh command `ssh-keygen -t rsa -b 4096` and share that public key you've just created with your server VM.
```
scp .ssh/id_rsa.pub  git@10.0.3.10:/home/git/.ssh/authorized_keys


Don't forget to configure the **/etc/ssh/sshd_config** file !
-> Change the parameter in PasswordAuthentication to:

    PasswordAuthentication no
```
systemctl restart sshd
```

/!\ If you get this error while trying to connect with SSH : 

```output
Permission denied (publickey,gssapi-keyex,gssapi-with-mic)
``` 

Check on your **/home/git** and ./ssh folders permissions ; 

    sudo chmod 0700 /home/git
    sudo chmod 0700 /home/git/.ssh

And also double-check on the /.ssh/authorized_keys permissions ;

    sudo chmod 0600 /home/git/.ssh/authorized_keys

Now it should works, if it doesn't refer to [this tutorial](https://phoenixnap.com/kb/ssh-permission-denied-publickey) .


## 5. Unit test to make my code perfect

In this example the unit test developped with dotnet will check on the code and see if it contains any non-english character in variables names (for example é, à or ù).

First you have to make sure that dotnet is correctly installed on VM your machine, if it's not the case install it with the following lines;

    sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
    sudo yum makecache
    sudo yum install dotnet-sdk-2.2



You'll send the CleanerApp folder to your server machine and then copy the bash script into a pre-commit file

On your local machine, share CleanerApp folder with the server...

    scp -r CleanerApp\ git@10.0.3.10:/home/git/clone

Then on your server as root user copy past the clean bash script to git's home folder and change permissions.

    cp /home/git/CleanerApp/CleanMyCode.sh /home/git/clone/hooks/pre-commit
    chmod +x /home/git/clone/hooks/pre-commit

And that's it! You'll now be able to check on your code so it doesn't contain any of those characters. Btw you can edit the CleanMyCode.sh and add your own features.

Your setup is now done but you can improve your VM server and make it more secure, continue this tuto if you're interested.

## 6. Security check

Let's resume, during this setup you gave to user et git users all root rights so you can share and communicate with your host machine through SSH and SCP protocols without using passwords and also to manipulate your files and folders on your VM. 

Now that we're done with the setup you don't need all of that, you'll now communicate with your server using with Git, 