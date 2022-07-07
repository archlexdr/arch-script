#!/bin/bash


### Instalar sistema
pacstrap /mnt base linux linux-firmware base-devel efibootmgr os-prober networkmanager grub gvfs nano netctl wpa_supplicant dialog xf86-input-synaptics udisks2 ntfs-3g bash-completion

genfstab -U /mnt >> /mnt/etc/fstab




### Configurar sistema
# arch-chroot /mnt
# ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime
# hwclock --systohc --utc

# nano /etc/locale.gen


# Zona horaria Automatica
arch-chroot /mnt /bin/bash -c "pacman -Sy curl --noconfirm"
curl https://ipapi.co/timezone > zonahoraria
zonahoraria=$(cat zonahoraria)
arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$zonahoraria /etc/localtime"
arch-chroot /mnt /bin/bash -c "timedatectl set-timezone $zonahoraria"
arch-chroot /mnt /bin/bash -c "pacman -S ntp --noconfirm"
arch-chroot /mnt /bin/bash -c "ntpd -qg"
arch-chroot /mnt /bin/bash -c "hwclock --systohc --utc"
sleep 3
rm zonahoraria
clear


arch-chroot /mnt
nano /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=en" > /etc/vconsole.conf
echo "wolf" > /etc/hostname




# Reloj
sed -i '/#NTP=/d' /etc/systemd/timesyncd.conf

sed -i 's/#Fallback//' /etc/systemd/timesyncd.conf

echo \"FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.fr.pool.ntp.org\" >> /etc/systemd/timesyncd.conf

systemctl enable systemd-timesyncd.service


echo -n "
127.0.0.1		localhost
::1		    	localhost
127.0.1.1		wolf.localhost wolf
" >> /etc/hosts



# Actualización de llaves y mirroslist del LIVECD
clear
pacman -Syy
pacman -Sy archlinux-keyring --noconfirm 
clear
pacman -Sy reflector python rsync glibc curl --noconfirm 
sleep 3
clear
echo ""
echo "Actualizando lista de MirrorList"
echo ""
reflector --verbose --latest 5 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist
clear
cat /etc/pacman.d/mirrorlist
sleep 3
clear




# Configurando pacman para que tenga colores con el repo de MultiLib
sed -i 's/#Color/Color/g' /mnt/etc/pacman.conf
sed -i 's/#TotalDownload/TotalDownload/g' /mnt/etc/pacman.conf
sed -i 's/#VerbosePkgLists/VerbosePkgLists/g' /mnt/etc/pacman.conf
sed -i "37i ILoveCandy" /mnt/etc/pacman.conf
sed -i 's/#[multilib]/[multilib]/g' /mnt/etc/pacman.conf
sed -i "s/#Include = /etc/pacman.d/mirrorlist/Include = /etc/pacman.d/mirrorlist/g" /mnt/etc/pacman.conf
clear




# Actualiza lista de mirrors en tu disco
echo ""
echo "Actualizando lista de MirrorList"
echo ""
arch-chroot /mnt /bin/bash -c "reflector --verbose --latest 15 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist"
clear
cat /mnt/etc/pacman.d/mirrorlist
sleep 3
clear




# passwd   <---
systemctl enable NetworkManager
grub-install --efi-directory=/boot/efi --bootlaoder-id='Arch Linux' --target=x86_64-efi

echo -n "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg
os-prober
grub-mkconfig -o /boot/grub/grub.cfg
useradd -m adrian
# passwd adrian     <---
usermod -aG wheel,audio,video,storage adrian
pacman -S sudo
sleep 2
clear

# Descomentamos el %wheel que este despues del utlimo root:
nano /etc/sudoers


# exit
# umount -R /mnt
# reboot
# # Sacar USB y arrancar PC



