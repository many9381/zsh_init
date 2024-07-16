#!/bin/bash

command_exists() {
    command -v "$@" >/dev/null 2>&1
}

is_run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        # True
        return 0
    else
        # False
        return 1
    fi
}

is_user_can_sudo() {
    # Check if sudo is installed
    command_exists sudo || return 1

    # Check user can sudo
    if ! sudo -v 2>/dev/null; then
        return 1
    fi

    return 0
}

run_as_sudo() {
    local result=0
    if is_run_as_root; then
        "${@}"
        result=$?
    fi

    if is_user_can_sudo; then
        sudo "${@}"
        result=$?
    else
        echo "Failed to run '${*}': Check sudo permission"
        result=1
    fi

    return "$result"
}

get_user_home_directory() {
    if check_rus_as_sudo; then
        getent passwd "$SUDO_USER" | cut -d: -f6
    else
        echo "$HOME"
    fi
}

