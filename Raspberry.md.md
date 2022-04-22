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


