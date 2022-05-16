#!/bin/bash
echo "Let's create VM which will be your personal server."
echo "Nice ok let's start..."

VMName="serverVM"
DiskSize=$((1024*200))
MemorySize=$((1024))
VRamSize=128
CPUCount=2
OSTypeID="RedHat_64"
 
#VBoxManage list vms
echo "Creating VM..."
VBoxManage createvm --name $VMName --ostype "$OSTypeID" --register --basefolder `pwd`

echo "Setting memory..."
VBoxManage modifyvm $VMName --memory $MemorySize --vram $VRamSize --cpus $CPUCount

echo "Creating disk..."
VBoxManage createhd --filename `pwd`/$VMName/$VMName.vdi --size $DiskSize --format VDI
 
 
echo "Adding the created disk to the VM..."
VBoxManage storagectl $VMName --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium `pwd`/$VMName/$VMName.vdi
 
VBoxManage storagectl $VMName --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $VMName --storagectl "IDE Controller" --port 1  --device 0 --type dvddrive --medium `pwd`/centos.iso
 

echo "Setting boot sequence..."
VBoxManage modifyvm $VMName --boot1 dvd --boot2 disk --boot3 none --boot4 none

Vboxmanage modifyvm $VMName --nic1 nat

VBoxManage unattended install $VMName \
--iso=centos.iso \
--user=user --full-user-name=user --password root \
--install-additions --time-zone=CET

echo "Creation completed ! Your VM will start now."
VBoxHeadless --startvm $VMName
read