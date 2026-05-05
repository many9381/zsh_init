#!/bin/bash

SETUP_HOME=${SETUP_HOME:-$HOME}
SETUP_USER=${SETUP_USER:-$USER}
SETUP_ROOT=${SCRIPT_DIR:-$(pwd)}
ZSH=${ZSH:-$SETUP_HOME/.oh-my-zsh}
ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}
ZSH_RC="$SETUP_HOME/.zshrc"

portable_sed_inplace() {
    local expression="$1"
    local file_path="$2"

    if sed --version >/dev/null 2>&1; then
        sed -i -e "$expression" "$file_path"
    else
        sed -i '' -e "$expression" "$file_path"
    fi
}

run_as_setup_user() {
    if [ "$USER" = "$SETUP_USER" ] && ! is_run_as_root; then
        "$@"
        return $?
    fi

    sudo -u "$SETUP_USER" "$@"
}

append_if_missing() {
    local line="$1"

    touch "$ZSH_RC"

    if ! grep -Fqx "$line" "$ZSH_RC" 2>/dev/null; then
        printf '%s\n' "$line" >> "$ZSH_RC"
    fi
}

current_plugins=$(
    sed -n 's/^[[:space:]]*plugins=(\(.*\))[[:space:]]*$/\1/p' "$ZSH_RC" 2>/dev/null | head -n 1
)
PLUGINS=()

add_plugin() {
    local plugin="$1"
    if ! echo "$current_plugins" | grep -qw "$plugin"; then
        PLUGINS+=("$plugin")
    else
        echo "Plugin '$plugin' already exists in .zshrc"
    fi
}

add_zinit_plugin() {
    local plugin="$1"
    if grep -Fqx "zinit light $plugin" "$ZSH_RC" 2>/dev/null; then
        echo "Plugin '$plugin' already exists in .zshrc"
        return
    fi

    append_if_missing "zinit light $plugin"
}

update_plugin() {
    for PLUGIN in "${PLUGINS[@]}"; do
        current_plugins="$current_plugins $PLUGIN"
    done

    updated_plugins=$(echo "$current_plugins" | tr ' ' '\n' | sort -u | tr '\n' ' ')
    portable_sed_inplace "/^plugins=/s/plugins=(.*)/plugins=(${updated_plugins})/" "$ZSH_RC"

}

# Install oh-my-zsh
install_oh_my_zsh() {
    run_as_setup_user sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    zsh_shell=$(command -v zsh)

    if [ -f /etc/shells ] && ! grep -qxF "$zsh_shell" /etc/shells; then
        printf '%s\n' "$zsh_shell" | run_as_sudo tee -a /etc/shells >/dev/null
    fi

    # If this user's login shell is already "zsh", do not attempt to switch.
    run_as_sudo chsh -s "$zsh_shell" "$SETUP_USER"

    # Install zsh plugin manager(zinit)
    run_as_setup_user env NO_INPUT=1 bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"

    # Install oh-my-zsh plugins

    # Install F-Sy-H
    add_zinit_plugin z-shell/F-Sy-H

    # Install zsh-autosuggestions
    add_zinit_plugin zsh-users/zsh-autosuggestions

    # Install zsh-256color
    add_zinit_plugin chrissicool/zsh-256color

    # Install zsh-completions
    add_zinit_plugin zsh-users/zsh-completions
    append_if_missing "autoload -U compinit && compinit"

    # Install oh-my-zsh full autoupdate
    # git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git "$ZSH_CUSTOM/plugins/ohmyzsh-full-autoupdate"
    # add_zinit_plugin Pilaton/OhMyZsh-full-autoupdate
    # add_plugin "ohmyzsh-full-autoupdate"

    # Install powerlevel10k
    append_if_missing "zinit ice depth=1"
    add_zinit_plugin romkatv/powerlevel10k
    cp "$SETUP_ROOT/config/p10k/.p10k.zsh" "$SETUP_HOME"
    append_if_missing "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh"

    # Install zsh-interactive-cd
    add_plugin zsh-interactive-cd

    # install tmuxinator
    add_plugin tmuxinator

    update_plugin
    run_as_setup_user zsh -i -c "zinit update --parallel"
}

update_zshrc() {
    local config_name="$1"
    local config_value="$2"
    local add_newline="${3:-false}"
    local config_command="$config_name=\"$config_value\""

    if grep -q "^$config_name=" "$ZSH_RC"; then
        # if config name exist
        portable_sed_inplace "s|^$config_name=.*|$config_command|" "$ZSH_RC"
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

    # Setting up an alias for eza in .zshrc
    update_zshrc "alias ls"     "eza --icons"
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

    # History settings in .zshrc
    update_zshrc "HISTSIZE" "5000"
    update_zshrc "SAVEHIST" "5000"
    # Write the history file in the ':start:elapsed;command' format.
    append_if_missing "setopt EXTENDED_HISTORY"
    # history file is updated immediately after a command is entered
    append_if_missing "setopt INC_APPEND_HISTORY"
    # Expire a duplicate event first when trimming history.
    append_if_missing "setopt HIST_EXPIRE_DUPS_FIRST"
    # Do not display a previously found event.
    append_if_missing "setopt HIST_FIND_NO_DUPS"
    # Delete an old recorded event if a new event is a duplicate.
    append_if_missing "setopt HIST_IGNORE_ALL_DUPS"
    # Do not record an event that was just recorded again.
    append_if_missing "setopt HIST_IGNORE_DUPS"
    # Do not record an event starting with a space.
    append_if_missing "setopt HIST_IGNORE_SPACE"
    # Do not write a duplicate event to the history file.
    append_if_missing "setopt HIST_SAVE_NO_DUPS"
    # Share history between all sessions.
    append_if_missing "setopt SHARE_HISTORY"
}
