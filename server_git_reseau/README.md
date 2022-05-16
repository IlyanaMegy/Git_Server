## Setup Raspbian OS

    DATA :
    ip addr = 192.168.1.10
    port ssh = 42
    user ssh = git
    passwd user = omiluk


First we gonna setup the Raspbian OS on our Raspberry with an image we'll install from our computer.
You can follow [this tutorial](https://www.raspberrypi.com/documentation/computers/getting-started.html) to do it yourself !

For me it'll be from my Windows computer and i'll be using Win32DiskImager to format and then install my Raspbian image on the Rasberry's SD card.

I also add 2 files to the others on the SD card that will help later, the first one will be `wpa_supplicant.conf` and will connect my Raspberry to my WIFI network :

```shell
country=FR
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
  scan_ssid=1
  ssid="Mon_Réseau_Wifi"
  psk="le_mot_de_passe_de_mon_réseau"
  key_mgmt=WPA-PSK
}
```
And the second is a simple `ssh` empty file to allow the ssh connection.

Once it's done i put that SD card in the Raspberry and start the installation, it may takes some times.
On startup I login and directly check for the wlan0 with the command `ip a` to see if the machine is well connected to my WIFI.

If not i recommand you to check the raspi-conf and add it yourself !
Use the command `sudo raspi-config`

![set internet network](https://cdn.discordapp.com/attachments/960877204491874316/967063336304914462/wirelessLan.png)
Then try a ping to 8.8.8.8 to test the internet connection.

Now i'm trying the connection from my computer to the Raspberry with Putty to test the ssh connection.

First i need to know the Raspberry's IP, to know it simply do the ip a command again, the ip is showing like this :

![find the ip](https://cdn.discordapp.com/attachments/960877204491874316/967066631887024238/ipa.png)

Ok now that we have the IP we can connect from Putty :

![putty](https://cdn.discordapp.com/attachments/960877204491874316/967067058988810280/putty2.png)


![putty connection](https://cdn.discordapp.com/attachments/960877204491874316/967065727968362596/putty.png)

## SSH config to secure

Our primal goal is to set a Git server on that Raspberry right?
But we want that for us and only us !
We'll then have to secure a bit all of that and we'll do it step by step.

First we will create a special user from which we can communicate to the server. This user will be the only way to access to the Raspberry.

Then we can change the port of SSH so that none can communicate with the server unless they know the port.

And only some IPs will be allowed to communicate with the server, so we will find a way to ban IPs that try to bruteforce the connection.

So to resume:
1. Change ip address to a static one
2. The communation will be only through that ''git'' user,
3. The communication with SSH will be from a different port and so you need to know which port it is to connnect,
4. after several attempts we will ban the IPs that try to bruteforce.

---

**1/ Change IP Addr to a static one**

It'll will be easier to have followed IP addresses that will be used to communicated with the server, so first we need to change the server's one.

Simple reminder we need to know our current IP but we also need the router's one as we're connected to WIFI.
Do a `ip route | grep wlan0` to get those.
Then go to the `/etc/dhcpcd.conf` file and scroll down until you get those lines and uncomment them to put the IP that you want and the router's IP :

![enter image description here](https://cdn.discordapp.com/attachments/960877204491874316/967097549909532773/wlan0.png)You can now reboot the Raspberry and connect again with ssh to see if the ip has changed well.

---

**2/ Create a git user and configure it**

This part is really short, to create new user you do the command :
```
sudo useradd git
```
and to set a password, you just do :
`sudo passwd git`

You enter the password you want and boom it's done.
Now let's configure the `/etc/ssh/sshd_config` file so that we can connect with ssh only through git.
To permit this just add  the followed line to the end of the file:
```
AllowUsers	git
```
---
**3/ Change the port**

In the same file on the top change the port 22 to the one you want. Me I chose the port 42.
Reboot the machine and try to connect with ssh and its new port.

---
**4/ Fail2ban**

Fail2ban scans log files and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc... Generally Fail2Ban is then used to update firewall rules to reject the IP addresses for a specified amount of time, although any arbitrary other action (e.g. sending an email) could also be configured. 

Fail2Ban is able to reduce the rate of incorrect authentications attempts however it cannot eliminate the risk that weak authentication presents. Configure services to use only two factor or public/private authentication mechanisms if you really want to protect services.

To install it on the Raspberry, [follow this tutorial](https://blog.swmansion.com/limiting-failed-ssh-login-attempts-with-fail2ban-7da15a2313b).

## Modem interface configuration

The last thing we need to do is to configure the internet modem so that any ssh request using our IP and port will redirect to the Raspberry.
To do that we will add a new rule that will allow it.
Go to your internet modem interface and on the tab Networking/network you should be able to add this rule. 
I show you mine as an example :

![enter image description here](https://cdn.discordapp.com/attachments/889061317321838627/973173482076635136/unknown.png)

You can now connect to your raspberry server using:
``ssh git@86.213.8.213 -p 42``

with user git and the public ip addr of the modem through port 42.
