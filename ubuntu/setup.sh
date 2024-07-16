#!/bin/bash

run_as_sudo apt update

# Install build-essential
run_as_sudo apt install git curl build-essential -y

# Install neovim
run_as_sudo apt install neovim -y

# Install bat
run_as_sudo apt install bat -y

# Install fzf
run_as_sudo apt install fzf -y

# Add bat link
run_as_sudo ln -s /usr/bin/batcat /usr/bin/bat

# Install tmux, tmuxinator, oh-my-tmux
run_as_sudo apt install tmux tmuxinator -y


if [ -d "$HOME/.tmux" ]; then
    echo "The directory oh-my-tmux already Installed"
    echo "Delete and Reinstall oh-my-tmux"
    rm -rf .tmux
fi

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

# Install zsh
run_as_sudo apt install zsh -y

# Install oh-my-zsh
install_oh_my_zsh

# Install Additional package
run_as_sudo apt install thefuck -y

# Install lsd
run_as_sudo apt install lsd -y

# Setting up an alias
setup_alias_zshrc