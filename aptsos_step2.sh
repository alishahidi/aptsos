error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

welcome() { \
    dialog --colors --title "\Z7\ZbStep 2 of Installing Aptsos!" --msgbox "\Z4Packages and Configurations will be installed in this step" 9 60

    dialog --colors --title "\Z7\ZbStay Active!" --yes-label "Continue" --no-label "Exit" --yesno "\Z4You might need enter sudo password!\n\nContinue installation?" 6 60
}

welcome || error "User choose to exit."

get_input () {
    local user_input=$(\
        dialog --title "$1" \
        --inputbox "$2" 8 40 \
        3>&1 1>&2 2>&3 3>&- \
        )
    echo $user_input
}

clear;
echo "##########################"
echo "## Install sound system ##"
echo "##########################"

sudo pacman --needed --ask 4 -Sy - < packages/sound.txt || error "Failed to install required packages."

clear;
echo "#####################################"
echo "## Install drivers and filesystems ##"
echo "#####################################"

sudo pacman --needed --ask 4 -Sy - < packages/drivers.txt || error "Failed to install required packages."

clear;
echo "###################"
echo "## Install fonts ##"
echo "###################"

sudo pacman --needed --ask 4 -Sy - < packages/fonts.txt || error "Failed to install required packages."

clear;
echo "####################"
echo "## Install themes ##"
echo "####################"

sudo pacman --needed --ask 4 -Sy - < packages/themes.txt || error "Failed to install required packages."

clear;
echo "#############################################################"
echo "## Install x server and Window Manager and needed packages ##"
echo "#############################################################"

sudo pacman --needed --ask 4 -Sy - < packages/gui.txt || error "Failed to install required packages."

clear;
echo "#################################"
echo "## Install aur package manager ##"
echo "#################################"

cd /tmp
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
cd ~

yay --noconfirm --needed -S nerd-fonts-fantasque-sans-mono autotiling kbdd-git

clear;
echo "#######################"
echo "## Activate services ##"
echo "#######################"

systemctl enable --user pipewire-pulse pipewire

clear;
echo "########################"
echo "## Instal wallpapers ##"
echo "#######################"

cd ~
xdg-user-dirs-update
cd Pictures
git clone https://github.com/alishahidi/wallpapers
mv wallpapers Wallpapers
cd ~

clear;
echo "######################"
echo "## Install Configs ##"
echo "######################"

cd ~
mkdir -p Git/alishahidi
cd Git/alishahidi
git clone https://github.com/alishahidi/dotfiles
cd dotfiles
sudo cp -r etc usr /
cp .config/* ~/.config
cp .xinitrc ~
cp .xprofile ~
cp .zshrc ~
cd ~

clear;
echo "#########################################################"
echo "## Installing Doom Emacs. This may take a few minutes. ##"
echo "#########################################################"
sudo pacman --noconfirm --needed -S emacs || error "Error install diolog."
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom -y install
~/.emacs.d/bin/doom sync

clear;
echo "#############################"
echo "## Make scripts executable ##"
echo "#############################"

find $HOME/.local/bin -type f -print0 | xargs -0 chmod 775
find $HOME/.config/scripts -type f -print0 | xargs -0 chmod 775
find $HOME/.config/i3/bin -type f -print0 | xargs -0 chmod 775

clear;
echo "###############################"
echo "## At first time using emacs           ##"
echo "## run `killall emacs`                 ##"
echo "## & run `/usr/bin/emacs --daemon`     ##"
echo "## & anser y for every question asked ##"
echo "###############################"

clear;
echo "##############################"
echo "## Aptsos step 2 complete   ##"
echo "##############################"

while true; do
    read -p "Do you want to reboot? recommended [Y/n] " yn
    case $yn in
        [Yy]* ) reboot;;
        [Nn]* ) break;;
        "" ) reboot;;
        * ) echo "Please answer yes or no.";;
    esac
done