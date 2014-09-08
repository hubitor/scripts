#!/bin/bash -x
#use sudo and install missing commands in case running not inside official
#arch image (ex. arch-bridge)
##############################   PRE-INSTALL SETUPS  #############################
install_arch_utils () {
	mkdir tmp && cd tmp
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/zsh-completion
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/pacstrap.in
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/genfstab.in
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/common
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/arch-chroot.in
	curl -O https://projects.archlinux.org/arch-install-scripts.git/plain/Makefile
	make
	$sudo make install
	cd .. && rm -rf tmp
}
test -e /usr/bin/sudo && sudo=sudo
test -e /usr/local/bin/arch-chroot || install_arch_utils
test -e /sbin/gdisk || pacman -Syy gdsik --noconfirm
#########################   PARTITIONS SETUP   #####################################
$sudo loadkeys fr
$sudo modprobe dm-mod
#$sudo gdisk << EOF
#/dev/sda
#n
#1
#
#
#8e00
#
#w
#y
#EOF
#$sudo pvcreate /dev/sda1
#$sudo vgcreate arch-vg /dev/sda1
#$sudp lvcreate -L 4G -C y -n swap_1 arch-vg
#$sudo lvcreate -l 100%FREE  -n root arch-vg
#$sudp mkfs.btrfs -f -L arch /dev/arch-vg/root
#$sudo mkswap /dev/arch-vg/swap_1
#$sudo mount /dev/arch-vg/root /mnt
#$sudo swapon /dev/arch-vg/swap_1
$sudo mkfs.btrfs -f -L Arch /dev/sda7
$sudo swapon /dev/sda3
#####################   SYSTEM BASE INSTALL   #################################
yes "" | $sudo pacstrap -i /mnt base base-devel ca-certificates vim abs # iw wireless_tools wpa_supplicant wpa_actiond dialog alsa-utils sudo usb_modeswitch connman ofono #grub
$sudo bash -c "genfstab -U -p /mnt >> /mnt/etc/fstab"

innerFnct(){
	##################   SYSTEM BASE SETUP   ####################################
	echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 > /etc/locale.conf
	export LANG=en_US.UTF-8
	loadkeys fr-pc
	cat << EOF > /etc/vconsole.conf
#KEYMAP=fr
KEYMAP=fr-latin9
#FONT=Lat2-Terminus16
FONT=lat9w-16
EOF
        ln -s /usr/share/zoneinfo/Africa/Tunis /etc/localtime
	hwclock --systohc --utc
	echo lejenome > /etc/hostname
	####################   MAKEPKG CONFIG   ######################################
#	sed -i "s/^CFLAGS=.*/CFLAGS=\"-march=native -O2 -pipe -fstack-protector --param=ssp-buffer-size=4 -D_FORTIFY_SOURCE=2\"/"  /etc/makepkg.conf
	sed -i "s/^CFLAGS=.*/CFLAGS=\"-march=native -O2 -pipe -fstack-protector --param=ssp-buffer-size=4 -flto\"/"  /etc/makepkg.conf
	sed -i "s/^CXXFLAGS=.*/CXXFLAGS=\"\${CFLAGS}\"/" /etc/makepkg.conf
	sed -i "s/#MAKEFLAGS=.*/MAKEFLAGS=\"-j$(nproc)\"/" /etc/makepkg.conf
	pacman-key --init
	pacman-key --populate archlinux
	####################   YAOURT SETUP    #####################################
	mkdir build && cd build
	curl -O https://aur.archlinux.org/packages/pa/package-query-git/package-query-git.tar.gz
	tar xvfz package-query-git.tar.gz
	cd package-query-git
	makepkg -si --asroot --noconfirm
#	pacman -U package-query-git-*.pkg.tar.xz --noconfirm
	cd ..
	curl -O https://aur.archlinux.org/packages/ya/yaourt-git/yaourt-git.tar.gz
	tar xvfz yaourt-git.tar.gz
	cd yaourt-git
	makepkg -si --asroot --noconfirm
	#pacman -U yaourt-git-*.pkg.tar.xz --noconfirm
	cd ../.. && rm -rf build
	yaourt -Sy byobu --noconfirm
	#####################   DE SETUP   ###################################
#	sudo pacman -S xorg-server xorg-xinit xorg-server-utils mesa xf86-video-ati xf86-input-synaptics ttf-dejavu --noconfirm
#	alsamixer
#	cat < EOF >> /etc/pacman.conf
#[hawaii]
#   Server = http://archive.maui-project.org/archlinux/$repo/os/$arch
#   SigLevel = Optional TrustAll
#EOF
#       yaourt -Syubb hawaii-meta-git --noconfirm
	yaourt -Syubb --noconfirm wayland weston mesa
	#####################   NETWORK SETUP   #####################################
#	wifi-menu
#	systemctl enable net-auto-wireless.service
	yaourt -Syubb --noconfirm ofono connman usb_modeswitchalse-utils wpa_actiond wpa_supplicant wireless_tools iw
	systemctl enable dhcpcd.service
	systemctl enable connman.service
	systemctl enable ofono.service
	#######################  BOOT SETUP   ###################################
#	sed -i "s/^\(HOOKS=.*\)\(filesystems.*\)/\1lvm2 \2/" /etc/mkinitcpio.conf
	mkinitcpio -p linux
#	grub-mkconfig -o /boot/grub/grub.cfg
#	grub-install --target=i386-pc --recheck /dev/sda
	######################   USERs ACCOUNTS SETUP   #############################
	useradd -m -G wheel,storage,power -s /bin/bash lejenome
	sed -i "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" /etc/sudoers
	passwd lejenome
	passwd
}
$sudo arch-chroot /mnt /bin/bash -xc "$(which innerFnct); innerFnct"

# umount -R /mnt
# reboot
