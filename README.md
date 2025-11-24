# 🚀 Serveur Git Perso

> **Tutoriel complet pour installer ton propre serveur Git** avec contrôle total sur tes données et ton infrastructure.

Ce projet te guide pas à pas dans la mise en place d'un serveur Git perso sur deux types d'infrastructures :

- 🖥️ **VM Locale** (VirtualBox + CentOS) - Pour développer et tester tranquilou
- 🍓 **Raspberry Pi** (Raspbian) - Pour avoir ton serveur accessible depuis partout

---

## 📋 Sommaire

### [1. 🏗️ Serveur Git en Local (VM VirtualBox)](#1-serveur-git-en-local-vm-virtualbox)
- [1.1 Création de la VM CentOS 7](#11-création-de-la-vm-centos-7)
- [1.2 Configuration réseau](#12-configuration-réeau)
- [1.3 Installation Git](#13-installation-git)
- [1.4 Configuration SSH sécurisée](#14-configuration-ssh-sécurisée)
- [1.5 Tests unitiques automatiques](#15-tests-unitiques-automatiques)

### [2. 🌐 Serveur Git en Réseau (Raspberry Pi)](#2-serveur-git-en-r%C3%A9seau-raspberry-pi)
- [2.1 Setup Raspbian OS](#21-setup-raspbian-os)
- [2.2 Configuration WiFi et SSH](#22-configuration-wifi-et-ssh)
- [2.3 Sécurisation SSH avancée](#23-sécurisation-ssh-avancée)
- [2.4 Configuration modem et accès internet](#24-configuration-modem-et-acc%C3%A8s-internet)

### [3. 🛠️ Fonctionnalités Avancées](#3-fonctionnalit%C3%A9s-avanc%C3%A9es)
- [3.1 CleanerApp - Nettoyage de code](#31-cleanerapp---nettoyage-de-code)
- [3.2 Pre-commit hooks](#32-pre-commit-hooks)
- [3.3 Sécurité renforcée](#33-sécurité-renforcée)

### [4. 📚 Ressources et Annexes](#4-ressources-et-annexes)
- [4.1 Scripts utiles](#41-scripts-utiles)
- [4.2 Dépannage](#42-dépannage)

---

## 🎯 Prérequis

- **Pour VM Locale** : VirtualBox installé, 4GB RAM minimum
- **Pour Raspberry** : Raspberry Pi 3+, carte SD 16GB+, accès routeur
- **Le reste** : Un peu de connaissance Linux/SSH/Git, mais rien de compliqué !

---

# 1. 🏗️ Serveur Git en Local (VM VirtualBox)

## 1.1 Création de la VM CentOS 7

### Téléchargements nécessaires

- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- [CentOS 7 ISO](https://www.centos.org/download/) (renommer en `centos.iso`)

### Configuration réseau

1. Ouvrir `File/Host Network Manager`
2. Ajouter une nouvelle interface réseau
3. Configurer l'IP : `10.0.3.1/24`

### Création automatisée

```bash
# Exécuter le script fourni
./create_CentOS_VM.sh
```

> ⏱️ **Note** : L'install peut prendre 15-30 minutes va prendre un ptit café !

## 1.2 Configuration Réseau

### Configuration initiale

- **Login** : `user`
- **Mot de passe** : `root`

### Clavier AZERTY (si nécessaire)

```bash
localectl set-locale LANG=fr
localectl set-keymap fr
```

### Droits utilisateur

```bash
su
usermod -aG root user
# Éditer /etc/sudoers et ajouter :
user    ALL=(ALL)    NOPASSWD: ALL
```

### IP Statique

Créer `/etc/sysconfig/network-scripts/ifcfg-enp0s8` :

```bash
NAME=enp0s8
DEVICE=enp0s8
BOOTPROTO=static
ONBOOT=yes
IPADDR=10.0.3.10
NETMASK=255.255.255.0
```

Redémarrage réseau :

```bash
sudo ifdown enp0s3 && sudo ifup enp0s3
```

## 1.3 Installation Git

### Sur ta machine locale

- **Windows** : [Git SCM](https://git-scm.com/download/win)
- **Linux** : `apt-get install git`

### Sur ta VM CentOS

```bash
# Installation Git
yum update
yum install git-core -y

# Création utilisateur git
su -
sudo useradd git
echo "root" | passwd --stdin git
usermod -aG wheel git

# Configuration dépôt
su git
mkdir /home/git/clone
cd /home/git/clone && git init --bare
```

### Utilisation

```bash
# Depuis ton projet local
git init
git add *
git commit -m "Initial commit"

# Configuration remote
git remote add origin ssh://git@10.0.3.10:/home/git/clone
git push origin master
```

## 1.4 Configuration SSH Sécurisée

### Génération clés SSH

**Sur ta VM (utilisateur git)** :

```bash
ssh-keygen -t rsa -b 4096
touch /home/git/.ssh/authorized_keys
chmod 600 /home/git/.ssh/authorized_keys
chmod 700 /home/git/.ssh
```

**Sur ta machine locale** :

```bash
ssh-keygen -t rsa -b 4096
scp .ssh/id_rsa.pub git@10.0.3.10:/home/git/.ssh/authorized_keys
```

### Désactivation authentification par mot de passe

Éditer `/etc/ssh/sshd_config`

```bash
PasswordAuthentication no
```

```bash
systemctl restart sshd
```

### ⚠️ Dépannage SSH

Si erreur `Permission denied (publickey,gssapi-keyex,gssapi-with-mic)`

```bash
sudo chmod 0700 /home/git
sudo chmod 0700 /home/git/.ssh
sudo chmod 0600 /home/git/.ssh/authorized_keys
```

## 1.5 Tests Unitiques Automatiques

### Installation .NET sur CentOS

```bash
sudo rpm -Uvh https://packages.microsoft.com/config/rhel/7/packages-microsoft-prod.rpm
sudo yum makecache
sudo yum install dotnet-sdk-2.2
```

### Configuration Pre-commit Hook

```bash
# Transférer CleanerApp
scp -r CleanerApp/ git@10.0.3.10:/home/git/clone

# Configurer le hook
cp /home/git/CleanerApp/CleanMyCode.sh /home/git/clone/hooks/pre-commit
chmod +x /home/git/clone/hooks/pre-commit
```

---

## 2. 🌐 Serveur Git en Réseau (Raspberry Pi)

## 2.1 Setup Raspbian OS

### Préparation carte SD

1. Télécharger [Raspbian](https://www.raspberrypi.com/documentation/computers/getting-started.html)
2. Utiliser Win32DiskImager pour flasher l'image
3. Ajouter deux fichiers sur la carte SD :

#### `wpa_supplicant.conf` (connexion WiFi)

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

#### `ssh` (fichier vide pour activer SSH)

### Premier démarrage

```bash
# Vérifier connexion WiFi
ip a | grep wlan0

# Test connexion internet
ping 8.8.8.8
```

## 2.2 Configuration WiFi et SSH

### Configuration réseau WiFi

Si pas de connexion automatique :

```bash
sudo raspi-config
# Choisir : Network Options → Wireless LAN
```

### Test connexion SSH depuis ton PC local

```bash
# Avec Putty ou :
ssh pi@<IP_RASPBERRY>
```

## 2.3 Sécurisation SSH Avancée

### Configuration finale

- **IP Statique** : `192.168.1.10`
- **Port SSH** : `42` (au lieu de 22)
- **Utilisateur dédié** : `git`
- **Mot de passe** : `omiluk`

### 1️⃣ IP Statique

Éditer `/etc/dhcpcd.conf` :

```bash
# Décommenter et configurer :
interface wlan0
static_ip_address=192.168.1.10/24
static_routers=192.168.1.1
static_domain_name_servers=192.168.1.1 8.8.8.8
```

### 2️⃣ Utilisateur Git dédié

```bash
sudo useradd git
sudo passwd git  # mot de passe : omiluk
```

### 3️⃣ Restriction SSH

Éditer `/etc/ssh/sshd_config` :

```bash
# Changement port
Port 42

# Restriction utilisateur
AllowUsers git
```

### 4️⃣ Protection contre brute-force

```bash
# Installation fail2ban
sudo apt install fail2ban

# Configuration basique
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## 2.4 Configuration Modem et Accès Internet

### Redirection de port

Dans l'interface de ton modem/routeur :

- **Port externe** : 42
- **Port interne** : 42
- **IP destination** : 192.168.1.10
- **Protocole** : TCP

### Connexion finale

```bash
ssh git@<VOTRE_IP_PUBLIQUE> -p 42
```

---

## 3. 🛠️ Fonctionnalités Avancées

## 3.1 CleanerApp - Nettoyage de Code

Application .NET qui vérifie :

- Variables avec caractères non-anglais (é, à, ù...)
- Conventions de nommage
- Code propre avant commit

## 3.2 Pre-commit Hooks

Automatisation des tests avant chaque commit :

```bash
# Script hook personnalisé
#!/bin/bash
dotnet run --project CleanerApp
if [ $? -ne 0 ]; then
    echo "❌ Code validation failed!"
    exit 1
fi
echo "✅ Code validation passed!"
```

## 3.3 Sécurité Renforcée

- **Clés RSA 4096 bits**
- **Port SSH personnalisé**
- **Fail2ban anti-brute-force**
- **Utilisateur dédié sans droits root**
- **Accès IP limité**

---

## 4. 📚 Ressources et Annexes

## 4.1 Scripts Utiles

**`create_CentOS_VM.sh`**
Script automatisé pour créer la VM VirtualBox CentOS 7.

**`CleanMyCode.sh`**
Hook de validation de code avant commit.

## 4.2 Dépannage

### Problèmes SSH courants

- **Permissions** : Vérifier droits `/home/git/.ssh/`
- **Clés** : Regénérer si nécessaire
- **Firewall** : Désactiver temporairement pour tests

### Problèmes réseau

- **IP statique** : Vérifier configuration `/etc/dhcpcd.conf`
- **Redirection port** : Tester avec `nmap`

---

## 🏆 Conclusion

Ce projet t'offre **une solution Git complète et sécurisée** avec :

✅ **Contrôle total** sur tes données  
✅ **Sécurité maximale** avec configuration avancée  
✅ **Automatisation** des tests et validations  
✅ **Accès flexible** (local ou internet)  
✅ **Coût minimal** (gratuit si matériel disponible)

**🎉 Félicitations !** Tu as maintenant un serveur Git perso et sécurisé !

## 🛠 Technologies utilisées

<div align="center">
  <img src="srcs/centos.svg" alt="CentOS" title="CentOS 7" width="60" style="margin: 10px;"/>
  <img src="srcs/raspberry-pi.svg" alt="Raspberry Pi" title="Raspberry Pi" width="60" style="margin: 10px;"/>
  <img src="srcs/virtualbox.svg" alt="VirtualBox" title="VirtualBox" width="60" style="margin: 10px;"/>
</div>

<div style="margin-top:10px;" align="center">
  <img src="srcs/CSharp.svg" alt="CSharp" title="CSharp" width="60" style="margin: 10px;"/>
  <img src="srcs/bash.svg" alt="Bash" title="Bash" width="60" style="margin: 10px;"/>
  <img src="srcs/DotNET_core.svg" alt="DotNET Core" title=".NET Core" width="60" style="margin: 10px;"/>
</div>
