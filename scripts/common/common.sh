#!/bin/bash

check_run_as_root() {
    if [ "$EUID" -eq 0 ]; then
        # True
        return 0
    else
        # False
        return 1
    fi
}

check_rus_as_sudo() {
    if [ -n "${SUDO_USER:-}" ]; then
        # True
        return 0
    else
        # False
        return 1
    fi
}

get_user_home_directory() {
    if check_rus_as_sudo; then
        getent passwd "$SUDO_USER" | cut -d: -f6
    else
        echo "$HOME"
    fi
}