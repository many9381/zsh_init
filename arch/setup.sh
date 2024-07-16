#!/bin/bash

run_as_sudo pacman -Syu --noconfirm

# Install build-essential
run_as_sudo pacman -S git curl base-devel --noconfirm

# Install yay
if ! command_exists yay; then
    git clone https://aur.archlinux.org/yay.git "$HOME"
    cd "$HOME/yay" && makepkg -si --noconfirm
fi

# Install neovim
yay -S neovim --noconfirm

# Install bat
yay -S bat --noconfirm

# Install fzf
yay -S fzf --noconfirm

# Add bat link
run_as_sudo ln -s /usr/bin/batcat /usr/bin/bat

# Install tmux, tmuxinator, oh-my-tmux
yay -S tmux tmuxinator --noconfirm

if [ -d "$HOME/.tmux" ]; then
    echo "The directory oh-my-tmux already Installed"
    echo "Delete and Reinstall oh-my-tmux"
    rm -rf .tmux
fi

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf
cp ~/.tmux/.tmux.conf.local ~

# Install zsh
yay -S zsh --noconfirm

# Install oh-my-zsh
install_oh_my_zsh

# Install Additional package
run_as_sudo yay -S install thefuck --noconfirm

# Install lsd
yay -S lsd --noconfirm
# Setting up an alias for lsd in .zshrc
update_zshrc "alias ls"     "lsd"
update_zshrc "alias l"      "ls -l"
update_zshrc "alias la"     "ls -a"
update_zshrc "alias lla"    "ls -la"
update_zshrc "alias lt"     "ls --tree" true

# Setting up an alias for nvim(neovim) in .zshrc
update_zshrc "alias vim" "nvim"
update_zshrc "alias vi" "nvim"
update_zshrc "alias vimdiff" "nvim -d"
update_zshrc "export EDITOR" "$(which nvim)" true

update_zshrc "POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD" "true" true