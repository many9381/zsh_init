#!/bin/bash

ZSH=${ZSH:-$HOME/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}
ZSH_RC="$HOME/.zshrc"

current_plugins=$(grep -oP '^[^#]*plugins=\(\K[^\)]*' "$ZSH_RC" 2>/dev/null || echo "")
PLUGINS=()

add_plugin() {
    local plugin="$1"
    if ! echo "$current_plugins" | grep -qw "$plugin"; then
        PLUGINS+=("$plugin")
    else
        echo "Plugin '$plugin' already exists in .zshrc"
    fi
}

update_plugin() {
    for PLUGIN in "${PLUGINS[@]}"; do
        current_plugins="$current_plugins $PLUGIN"
    done

    updated_plugins=$(echo "$current_plugins" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    sed -i -e "/^plugins=/s/plugins=\(.*\)/plugins=(${updated_plugins})/" "$ZSH_RC"

}

# Install oh-my-zsh
install_oh_my_zsh() {    
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    zsh_shell=$(command -v zsh)

    # If this user's login shell is already "zsh", do not attempt to switch.
    run_as_sudo chsh -s "$zsh_shell" "$USER"

    # Install oh-my-zsh plugins

    # Install F-Sy-H
    git clone https://github.com/z-shell/F-Sy-H.git "$ZSH_CUSTOM/plugins/F-Sy-H"
    add_plugin "F-Sy-H"

    # Install zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    add_plugin "zsh-autosuggestions"

    # Install zsh-256color
    git clone https://github.com/chrissicool/zsh-256color "$ZSH_CUSTOM/plugins/zsh-256color"
    add_plugin "zsh-256color"

    # Install oh-my-zsh full autoupdate
    git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git "$ZSH_CUSTOM/plugins/ohmyzsh-full-autoupdate"
    add_plugin "ohmyzsh-full-autoupdate"

    # Install powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    sed -i -e 's/^ZSH_THEME=.*$/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSH_RC"
    cp ./config/p10k/.p10k.zsh ~
    echo -e "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n" >> "$ZSH_RC"


    # Install zsh-interactive-cd
    add_plugin zsh-interactive-cd

    # install tmuxinator
    add_plugin tmuxinator

    update_plugin
}

update_zshrc() {
    local config_name="$1"
    local config_value="$2"
    local add_newline="${3:-false}"
    local config_command="$config_name=\"$config_value\""

    if grep -q "^$config_name=" "$ZSH_RC"; then
        # if config name exist
        sed -i -e "s|^$config_name=.*|$config_command|" "$ZSH_RC"
    else
        # if config name does not exist, append it to the end
        if [ "$add_newline" = true ]; then
            echo -e "$config_command\n" >> "$ZSH_RC"
        else
            echo "$config_command" >> "$ZSH_RC"
        fi
    fi
}

setup_alias_zshrc() {
    # Setting up an alias for bat in .zshrc
    update_zshrc "alias cat"     "bat" true

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
}