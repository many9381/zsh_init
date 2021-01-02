#!/bin/bash

#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root"
#  exit
#fi

# install zsh
sudo apt install zsh thefuck build-essential -y

# install snap
#sudo 


# Set ZSH, ZSH_CUSTOM
ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

# installing oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install oh-my-zsh plugins

# install fast-syntax-highlighting
git clone https://github.com/zdharma/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting

# install zsh-autosuggestions
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# install powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# install zsh-256color
git clone https://github.com/chrissicool/zsh-256color $ZSH_CUSTOM/plugins/zsh-256color

# copy zshrc to local zshrc
cp ./zshrc ~/.zshrc

# change default shell
echo "Change default shell to zsh"

zsh=$(which zsh)
chsh -s "${zsh}"

#install lsd
echo "Install lsd"
wget https://github.com/Peltoche/lsd/releases/download/0.19.0/lsd_0.19.0_amd64.deb
sudo dpkg -i lsd_0.19.0_amd64.deb

echo "Remove lsd install file"
rm lsd_0.19.0_amd64.deb


zsh

# apply .zshrc
#source ~/.zshrc
