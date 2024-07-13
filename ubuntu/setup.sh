#!/bin/bash

run_as_sudo apt update

# Install build-essential
run_as_sudo apt install git curl build-essential -y

# Install neovim
run_as_sudo apt install neovim -y

# Install bat
run_as_sudo apt install bat -y

# Add bat link
run_as_sudo ln -s /usr/bin/batcat /usr/bin/bat

# Install tmux, tmuxinator, oh-my-tmux
run_as_sudo apt install tmux tmuxinator -y


if [ -d "$HOME/.tmux" ]; then
    echo "The directory oh-my-tmux already Installed"
    echo "Delete and Reinstall oh-my-tmux"
    rm -rf .tmux
fi

git clone https://github.com/gpakosz/.tmux.git ~
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

# Install zsh
run_as_sudo apt install zsh -y

# Install oh-my-zsh
# ZSH="${HOME}/.oh-my-zsh"
# ZSH_CUSTOM="$ZSH/custom"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

zsh_shell=$(command -v zsh)

# If this user's login shell is already "zsh", do not attempt to switch.
run_as_sudo chsh -s "$zsh_shell" "$USER"

# Install Additional package
run_as_sudo apt install thefuck -y