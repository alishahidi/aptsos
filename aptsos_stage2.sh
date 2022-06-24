error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

welcome() { \
    dialog --colors --title "\Z7\ZbStage 2 of Installing Aptsos!" --msgbox "\Z4Packages and Configurations will be installed in this stage" 9 60

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

sudo reflector --sort score --latest 10 --protocol http,https --save /etc/pacman.d/mirrorlist

sudo pacman -Sy

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
makepkg -si --noconfirm
cd ~

yay --noconfirm --needed -S nerd-fonts-fantasque-sans-mono nerd-fonts-inconsolata

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
echo "## Fix some problem ##"
echo "#######################"

# Disable random mac address
echo -e "[device]\nwifi.scan-rand-mac-address=no" | sudo tee /etc/NetworkManager/conf.d/disable-random-mac.conf

# tap to click
echo 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/40-libinput.conf

clear;
echo "#########################################"
echo "## Install zsh and oh-my-zsh framework ##"
echo "#########################################"


sudo pacman --noconfirm --needed -S zsh wget exa figlet lolcat curl git fzf || error "Error install diolog."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/agkozak/zsh-z $ZSH_CUSTOM/plugins/zsh-z

echo "##########################"
echo "## Change default shell ##"
echo "##########################"

chsh -s $(which zsh)

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
cp -r .config/* ~/.config
cp .xinitrc ~
cp .xprofile ~
cp .zshrc ~
cd ~

clear;
echo "########################"
echo "## Install dmenu_apts ##"

For install stage2 run =bash aptsos_stage2.sh=
echo "########################"

cd ~
cd Git/alishahidi
git clone https://github.com/alishahidi/dmenu_apts
cd dmenu_apts
sudo make install
cd ~

clear;
echo "#########################################################"
echo "## Installing Doom Emacs. This may take a few minutes. ##"
echo "#########################################################"
sudo pacman --noconfirm --needed -S emacs
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom -! install
~/.emacs.d/bin/doom sync

clear;
echo "#############################"
echo "## Make scripts executable ##"
echo "#############################"

find $HOME/.local/bin -type f -print0 | xargs -0 chmod 775
find $HOME/.config/scripts -type f -print0 | xargs -0 chmod 775
find $HOME/.config/status_scripts -type f -print0 | xargs -0 chmod 775

clear;
echo "########################################"
echo "## At first time using emacs          ##"
echo "## run killall emacs                  ##"
echo "## & run /usr/bin/emacs --daemon      ##"
echo "## & anser y for every question asked ##"
echo "########################################"

clear;
echo "##############################"
echo "## Aptsos stage 2 complete   ##"
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
