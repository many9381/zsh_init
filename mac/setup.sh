#!/bin/bash

TARGET_USER=${SUDO_USER:-$USER}
TARGET_HOME=$(eval "printf '%s' ~$TARGET_USER")
SETUP_HOME="$TARGET_HOME"
SETUP_USER="$TARGET_USER"
export SETUP_HOME
export SETUP_USER

run_as_user() {
    if [ "$USER" = "$TARGET_USER" ] && ! is_run_as_root; then
        "$@"
        return $?
    fi

    sudo -u "$TARGET_USER" "$@"
}

setup_iterm2_profile() {
    local profile_name="Forest"
    local profile_guid="53B780A8-CC16-4F03-8FB4-587220FC89FC"
    local profile_source="$SCRIPT_DIR/config/iterm/Forest.json"
    local dynamic_profiles_dir="$TARGET_HOME/Library/Application Support/iTerm2/DynamicProfiles"
    local profile_target="$dynamic_profiles_dir/$profile_name.json"

    if [ ! -f "$profile_source" ]; then
        echo "iTerm2 profile not found: $profile_source"
        return 1
    fi

    run_as_user mkdir -p "$dynamic_profiles_dir"

    PROFILE_SOURCE="$profile_source" PROFILE_TARGET="$profile_target" run_as_user /bin/sh -c '
        awk '"'"'BEGIN { print "{\n  \"Profiles\": [" } { print } END { print "\n  ]\n}" }'"'"' "$PROFILE_SOURCE" > "$PROFILE_TARGET"
    '

    run_as_user defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$profile_guid"
    run_as_user defaults write com.googlecode.iterm2 "NoSyncDefaultBookmarkGuid" -string "$profile_guid"
}

ensure_homebrew() {
    if command_exists brew || [ -x /opt/homebrew/bin/brew ] || [ -x /usr/local/bin/brew ]; then
        return 0
    fi

    NONINTERACTIVE=1 run_as_user /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_homebrew_env() {
    if [ -x /opt/homebrew/bin/brew ]; then
        BREW_BIN=/opt/homebrew/bin/brew
        eval "$(/opt/homebrew/bin/brew shellenv)"
        return 0
    fi

    if [ -x /usr/local/bin/brew ]; then
        BREW_BIN=/usr/local/bin/brew
        eval "$(/usr/local/bin/brew shellenv)"
        return 0
    fi

    return 1
}

ensure_homebrew
load_homebrew_env || {
    echo "Homebrew is not available"
    exit 1
}

run_as_user "$BREW_BIN" update
run_as_user "$BREW_BIN" install git curl neovim bat tmux tmuxinator zsh thefuck eza fzf
run_as_user "$BREW_BIN" tap homebrew/cask-fonts
run_as_user "$BREW_BIN" install --cask font-iosevka-nerd-font font-d2coding-nerd-font font-hack-nerd-font

if [ -d "$TARGET_HOME/.tmux" ]; then
    echo "The directory oh-my-tmux already Installed"
    echo "Delete and Reinstall oh-my-tmux"
    rm -rf "$TARGET_HOME/.tmux"
fi

run_as_user git clone https://github.com/gpakosz/.tmux.git "$TARGET_HOME/.tmux"
run_as_user ln -sf "$TARGET_HOME/.tmux/.tmux.conf" "$TARGET_HOME/.tmux.conf"
run_as_user cp "$TARGET_HOME/.tmux/.tmux.conf.local" "$TARGET_HOME"
setup_iterm2_profile

FZF_INSTALLER="$("$BREW_BIN" --prefix)/opt/fzf/install"
if [ -x "$FZF_INSTALLER" ]; then
    run_as_user "$FZF_INSTALLER" --all --no-bash
fi

# Install oh-my-zsh
install_oh_my_zsh

# Setting up an alias
setup_alias_zshrc
