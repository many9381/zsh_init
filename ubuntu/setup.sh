#!/bin/bash

apt update

# Install build-essential
apt install git curl build-essential -y

# Install neovim
apt install neovim -y

# Install bat
apt install bat -y

# Add bat link
ln -s /usr/bin/batcat /usr/bin/bat

# Install tmux, tmuxinator, oh-my-tmux
apt install tmux tmuxinator -y

if [ -d "$HOME/.tmux" ]; then
    echo "The directory oh-my-tmux already Installed"
    echo "Delete and Reinstall oh-my-tmux"
    rm -rf .tmux
fi

git clone https://github.com/gpakosz/.tmux.git ~
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

# Install zsh
apt install zsh -y

# Install oh-my-zsh
# ZSH="${HOME}/.oh-my-zsh"
# ZSH_CUSTOM="$ZSH/custom"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

zsh_shell=$(command -v zsh)

# If this user's login shell is already "zsh", do not attempt to switch.
if [ ! "$(basename -- "$SHELL")" = "zsh" ]; then
    if [ -z "${SUDO_USER:-}" ]; then
        # Run from root
        chsh -s "$zsh_shell" "$USER"
    else
        # Run from user(sudo)
        chsh -s "$zsh_shell" "$SUDO_USER"
    fi
fi

# Install Additional package
apt install thefuck -y