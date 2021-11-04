# Install your own Git server on a VM

Hi! Here's  a tuto to set up your server. Not really complicated, just follow the instructions step by step.

## 1. Create the VM

For this tutorial I chose to use a CentOS7 iso, you can adapt the followed bash script if you prefer another Linux distrib..
We'll start with the VM's Setup, to make it quicker for you i've wrote a little bash script called **create_CentOS_VM.sh**. 
-> Just execute it and enter the asked lines. 

At this point you must have noticed your VM infos, just also know that your login is **user** and password **root**, you'll be able to change it later...

Next we have to configure your static IP, just copy those lines into the `/etc/sysconfig/network-scripts/ifcfg-enp0s3` file.

```
NAME=enp0s3
DEVICE=enp0s3
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.30.10
NETMASK=255.255.255.0
```
save and exit the file then use ,
```
sudo ifdown enp0s3
sudo ifup enp0s3
```
You're now able to see your static IP address by using the cmd `ip a`.
We can now connect to your local machine with SSH and also to share some files and so will you !

Also let's give to user all rights just like root have.

    su
    usermod -aG root user
then modify /etc/sudoers file and add this like under root's one:

    user	ALL=(ALL)	NOPASSWD: ALL

## 2. SSH-keygen

To simplify your interactions with your server, you better set-up a password-less ssh login. 
-> Execute the **generate_SSH_key.sh** file.

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
Check on your **/home/your_name** and ./ssh folders permissions ; 

    sudo chmod 0700 /home/your_name
    sudo chmod 0700 /home/your_name/.ssh

Then check on the /.ssh/authorized_keys file ;

    sudo chmod 0600 /home/your_name/.ssh/authorized_keys

Now it should works, if it doesn't refer to [this tutorial](https://phoenixnap.com/kb/ssh-permission-denied-publickey) .

## 3. Install git

Once that's done we can start the real set-up.
We will install git on both machines, so you can use the VM as a git server.

To install git on your local machine, if it's on a Windows' OS go download it on [this website](https://git-scm.com/download/win) and follow the installations instructions. 
If your machine is on Linux execute this command :

    apt-get install git

Then we will install it on your VM, follow those commands :
```
#install git
yum install git-core -y

#create git user
sudo useradd git
echo  "root" | passwd --stdin git
usermod -aG wheel git

#create the saved-files-folder and git init
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
    git commit "updated work on 18/01/21"

and git git remote to your server before push.

    git remote add origin ssh://git@192.168.30.20:/home/git/clone
    git push origin master
And that's it.
Now let's try to create a check-in-before-commit program.
We will just ask git to execute our unit test just before it commits our code.

## 4. Unit test to make my code perfect

In this example the unit test developped with dotnet will check on the code and see if it contains any non-english character in variables names (for example é, à or ù).

You'll send the CleanerApp folder to your server machine and then copy the bash script into a pre-commit file

    scp -r CleanerApp\ user@192.168.30.10:/home/user
    ssh user@192.168.30.10 "cp /home/user/CleanerApp/CleanMyCode.sh /home/git/clone/hooks/pre-commit"
    ssh user@192.168.30.10 "chmod +x /home/git/clone/hooks/pre-commit"

