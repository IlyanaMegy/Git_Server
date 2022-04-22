## Setup Raspbian OS

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

![set internet network](https://cdn.discordapp.com/attachments/960877204491874316/967063336304914462/wirelessLan.png)Then try a ping to 8.8.8.8 to test the internet connection.

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

First we will create a special user from which we can communicate to the server. This user will be able to do some actions but to stay safe it will not be able to access to all folders or files of the Raspberry.

Then we will assure that we can communicate with SSH without password and we will not allow a connection with a password to enforce the security. Also only some IPs will be allowed to communicate with the server.

And then we can also change the port of SSH so that none can communicate with the server unless they know the port.

So to resume:
1. The communation will be only through that ''git'' user,
2. only some people (IPs) will have the right to communicate with the server,
3. The communication with SSH will not be from port 22 and so you need to know which port it is.

