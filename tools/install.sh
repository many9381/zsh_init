#!/bin/bash

#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root"
#  exit
#fi

# Install zsh
# ------------------------------------------------------------
sudo apt update
sudo apt install zsh git curl thefuck build-essential -y

# Install lazygit
# ------------------------------------------------------------
sudo add-apt-repository ppa:lazygit-team/release
sudo apt-get update
sudo apt-get install lazygit

# Install bat
# ------------------------------------------------------------
sudo apt install bat

# Add bat link
# ------------------------------------------------------------
sudo ln -s /usr/bin/batcat /usr/bin/bat


# Install tmux, tmuxinator, oh-my-tmux
# ------------------------------------------------------------
sudo apt install tmux tmuxinator

git clone https://github.com/gpakosz/.tmux.git ~
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

# Set ZSH, ZSH_CUSTOM
# ------------------------------------------------------------
ZSH="${HOME}/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

# Installing oh-my-zsh
# ------------------------------------------------------------
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# install oh-my-zsh plugins

# Install fast-syntax-highlighting
# ------------------------------------------------------------
git clone https://github.com/zdharma/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting

# Install zsh-autosuggestions
# ------------------------------------------------------------
git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

# Install powerlevel10k
# ------------------------------------------------------------
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

# Install zsh-256color
# ------------------------------------------------------------
git clone https://github.com/chrissicool/zsh-256color $ZSH_CUSTOM/plugins/zsh-256color

# copy zshrc to local zshrc
# ------------------------------------------------------------
cp ../zshrc ~/.zshrc

# Install fzf
# ------------------------------------------------------------
echo "Install fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# change default shell
# ------------------------------------------------------------
echo "Change default shell to zsh"

zsh=$(which zsh)
chsh -s "${zsh}"

# Install lsd
# ------------------------------------------------------------
echo "Install lsd"
wget https://github.com/Peltoche/lsd/releases/download/0.19.0/lsd_0.19.0_amd64.deb
sudo dpkg -i lsd_0.19.0_amd64.deb

echo "Remove lsd install file"
rm lsd_0.19.0_amd64.deb

# Install zplug
# ------------------------------------------------------------
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# Install zplugins
# ------------------------------------------------------------
zplug install | zsh

zsh

# apply .zshrc
#source ~/.zshrc
