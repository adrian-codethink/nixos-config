# nixos-config

## running in a vm

create a vm disk image
```
mkdir ~/vm
cd ~/vm
qemu-img create -f qcow2 nixos-test.img 20G
```
run this to start installation
```
qemu-system-x86_64 -enable-kvm -boot d -cdrom /var/lib/libvirt/isos/nixos-minimal-24.05.5197.944b2aea7f0a-x86_64-linux.iso -m 8G -cpu host -smp 4 -hda nixos-test.img
```
Then inside the VM ou can install using the following commands. (replace /ev/sda with what you find with fdisk -l
```
sufo fdisk -l
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko#disko-install -- --flake github:adrian-codethink/nixos-config#nixos-vm --write-efi-boot-entries --disk main /dev/sda
```
once complete, run 
```
poweroff
```

then in the host terminal
```
qemu-system-x86_64 -enable-kvm -boot d -bios /usr/share/ovmf/OVMF.fd -m 8G -cpu host -hda nixos-test.img
```
Once back up you can login with root:root and clone the repo to start customising the install
```
git clone https://github.com/adrian-codethink/nixos-config.git
cd nixos-config
sudo nixos-rebuild switch --flake .
```
