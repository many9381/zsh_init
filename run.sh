#!/bin/bash

OS_ARCHLINUX="Arch Linux"
OS_ENDEAVOUR="EndeavourOS"
OS_UBUNTU="Ubuntu"
OS_RASPBERRY_PI="Raspberry Pi"
OS_MAC_APPLE_SILICON="macOS (Apple Silicon)"
OS_MAC_INTEL="macOS (Intel)"
OS_FAMILY_DEBIAN="Debian Family"
OS_FAMILY_ARCH="Arch Family"

SCRIPT_DIR=$(
    cd -- "$(dirname -- "$0")" >/dev/null 2>&1 && pwd -P
)

detect_os() {
    local kernel_name machine_name distro_id distro_like distro_name

    kernel_name=$(uname -s 2>/dev/null)
    machine_name=$(uname -m 2>/dev/null)

    if [ "$kernel_name" = "Darwin" ]; then
        if [ "$machine_name" = "arm64" ]; then
            echo "$OS_MAC_APPLE_SILICON"
        else
            echo "$OS_MAC_INTEL"
        fi
        return 0
    fi

    if [ "$kernel_name" != "Linux" ] || [ ! -r /etc/os-release ]; then
        return 1
    fi

    distro_id=""
    distro_like=""
    distro_name=""
    . /etc/os-release
    distro_id=${ID:-}
    distro_like=${ID_LIKE:-}
    distro_name=${NAME:-}

    case "$distro_id" in
        ubuntu)
            echo "$OS_UBUNTU"
            return 0
            ;;
        raspbian)
            echo "$OS_RASPBERRY_PI"
            return 0
            ;;
        arch)
            echo "$OS_ARCHLINUX"
            return 0
            ;;
        endeavouros)
            echo "$OS_ENDEAVOUR"
            return 0
            ;;
    esac

    case " $distro_like " in
        *" debian "*)
            echo "$OS_FAMILY_DEBIAN"
            return 0
            ;;
        *" arch "*)
            echo "$OS_FAMILY_ARCH"
            return 0
            ;;
    esac

    case "$distro_name" in
        *"Raspberry Pi"*)
            echo "$OS_RASPBERRY_PI"
            return 0
            ;;
    esac

    return 1
}


source "$SCRIPT_DIR/scripts/common/common.sh"
source "$SCRIPT_DIR/scripts/oh-my-zsh/ohmyzsh.sh"

if ! is_run_as_root && ! is_user_can_sudo; then
	echo "Please run as root or check sudo"
	exit 1
fi

# Check OS
OS_NAME=$(detect_os)

if [ -z "$OS_NAME" ]; then
    echo "Unsupported operating system"
    exit 1
fi

echo "Operating System: $OS_NAME"

case "$OS_NAME" in
    "$OS_MAC_APPLE_SILICON"|"$OS_MAC_INTEL")
        source "$SCRIPT_DIR/mac/setup.sh"
        ;;
    "$OS_UBUNTU"|"$OS_RASPBERRY_PI"|"$OS_FAMILY_DEBIAN")
        source "$SCRIPT_DIR/ubuntu/setup.sh"
        ;;
    "$OS_ARCHLINUX"|"$OS_ENDEAVOUR"|"$OS_FAMILY_ARCH")
        source "$SCRIPT_DIR/arch/setup.sh"
        ;;
    *)
        echo "Unsupported operating system: $OS_NAME"
        exit 1
        ;;
esac
