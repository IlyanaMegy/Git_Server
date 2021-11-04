#!/bin/bash
echo "Let's create VM which will be your personla server."
echo "First tell me where do you want to save your VM."
read $savepath
echo "Great choice ! Now tell me, where did you put your iso file ? (for CentOS-7)"
read $isopath
echo "Nice ok, now we can start..."

VMName="serverVM"
VMDiskRoot="$savepath"
DiskDir="$VMDiskRoot/$VMName"
DiskSize=$((1024*200))
MemorySize=$((1024))
VRamSize=128
CPUCount=2
OSTypeID="RedHat_64"
ISOFilePath="$isofilepath"
 
echo "Creating $VMName disk at $DiskDir. Its size is $DiskSize."
if [ ! -d "$DiskDir" ]; then
    mkdir -p $DiskDir
fi
 
#VBoxManage list vms
echo "Creating disk..."
VBoxManage createhd --filename "$DiskDir/$VMName.vdi" --size $DiskSize 
 
echo "Creating VM..."
VBoxManage createvm --name $VMName --ostype "$OSTypeID" --register
 
echo "Adding the created disk to the VM..."
VBoxManage storagectl $VMName --name "SATA Controller" --add sata --portcount 1 --controller IntelAHCI
VBoxManage storageattach $VMName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DiskDir/$VMName.vdi"
 
VBoxManage storagectl $VMName --name "IDE Controller" --add ide
VBoxManage storageattach $VMName --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISOFilePath"
 
echo "Setting memory..."
VBoxManage modifyvm $VMName --memory $MemorySize --vram $VRamSize --cpus $CPUCount
 
echo "Setting boot sequence..."
VBoxManage modifyvm $VMName --boot1 dvd --boot2 disk --boot3 none --boot4 none
 
echo "Setting network..."
vboxmanage hostonlyif create
vboxmanage hostonlyif ipconfig "VirtualBox Host-Only Ethernet Adapter #1001" --ip 192.168.30.1
Vboxmanage modifyvm $VMName --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter #1001"
Vboxmanage modifyvm $VMName --nic1 hostonly

VBoxManage unattended install $VMName \
--iso=$ISOFilePath \
--user=user --full-user-name=user --password root \
--install-additions --time-zone=CET

echo "Creation completed ! Your VM will start now."
VBoxHeadless --startvm $VMName
read