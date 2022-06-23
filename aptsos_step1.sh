error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

clear;
echo "##########################################"
echo "## installing 'dialog' if not installed ##"
echo "##########################################"
pacman --noconfirm --needed -S dialog || error "Error install diolog."

welcome() { \
    dialog --colors --title "\Z7\ZbInstalling Aptsos!" --msgbox "\Z4I have created an installer for Arch Linux.\nAnd this installer is the next version of the installer that was in my dotfiles.\nMy configs and programs will be installed in this script." 9 60

    dialog --colors --title "\Z7\ZbStay Active!" --yes-label "Continue" --no-label "Exit" --yesno "\Z4Do You want continue installation?" 6 60
}

welcome || error "User choose to exit."

lastchance() { \
    dialog --colors --title "\Z7\ZbInstalling Aptsos!" --msgbox "\Z4WARNING! The APTSOS installation script made for myself. This may not work for you; therefore, it is strongly recommended that you not install this on production machines. It is recommended that you try this out in either a virtual machine or on a test machine." 10 60

    dialog --colors --title "\Z7\ZbAre You Sure You Want To Do This?" --yes-label "Begin Installation" --no-label "Exit" --yesno "\Z4Shall we begin installing Aptsos?" 6 60 || { clear; exit 1; }
}

lastchance || error "User choose to exit."

get_input () {
    local user_input=$(\
        dialog --title "$1" \
        --inputbox "$2" 8 40 \
        3>&1 1>&2 2>&3 3>&- \
        )
    echo $user_input
}

timezone=$(get_input "Get timezone" "Enter your timezone: ex: Asia/Tehran")
clear;

ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
sed -i '177s/.//' /etc/locale.gen
locale-gen

hostname=$(get_input "Get hostname" "Enter your hostname:")
clear;
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo $hostname >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >> /etc/hosts


dialog --colors --title "Set root password" --msgbox "Plese enter password please." 9 60
clear;
passwd

username=$(get_input "Get username" "Enter your username:")
clear;
useradd -m $username
usermod -aG wheel ali

dialog --colors --title "Set $username password" --msgbox "Plese enter password please." 9 60
clear;

passwd $username

echo 'wheel  ALL=(ALL:ALL) ALL' >> /etc/sudoers
echo "$username  ALL=(ALL:ALL) ALL" >> /etc/sudoers

clear;
pacman --needed --ask 4 -Sy - < packages/base.txt || error "Failed to install required packages."

clear;
echo "##############################"
echo "## Install Grub boot loader ##"
echo "##############################"

while true; do
    read -p "Is your system efi? [Y/n] " yn
    case $yn in
        [Yy]* )
            grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
            grub-mkconfig -o /boot/grub/grub.cfg
            break
        ;;
        [Nn]* )
            grub-install /dev/sda
            grub-mkconfig -o /boot/grub/grub.cfg
            break
        ;;
        "" ) reboot;;
        * ) echo "Please answer yes or no.";;
    esac
done

clear;
echo "#######################"
echo "## Activate services ##"
echo "#######################"

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable sshd
systemctl enable avahi-daemon
systemctl enable reflector.timer
systemctl enable fstrim.timer
systemctl enable firewalld
systemctl enable acpid
systemctl enable reflector

clear;
echo "#####################################################"
echo "## Step 1 installation complete                    ##"
echo "## Please exit form chroot with `exit` and         ##"
echo "## & unmount all partition with `umount -a`        ##"
echo "## & reboot with `reboot`                          ##"
echo "## ** After rebooting run step2 of installation ** ##"
echo "#####################################################"
