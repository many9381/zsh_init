#!/bin/bash

OS_ARCHLINUX="Arch Linux"
OS_ENDEAVOUR="EndeavourOS"
OS_UBUNTU="Ubuntu"

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")


source "$SCRIPT_DIR/scripts/common/common.sh"

if ! is_run_as_root && ! is_user_can_sudo; then
	echo "Please run as root or sudo"
	return
fi

# Check OS
OS_NAME=$(sed -n 's/^NAME=//p' /etc/os-release | tr -d '"')
echo "Operating System: $OS_NAME"

if [ "$OS_NAME" = "$OS_UBUNTU" ]; then
	source ubuntu/setup.sh
	return
fi

if [ "$OS_NAME" = "$OS_ARCHLINUX" ] || [ "$OS_NAME" = "$OS_ENDEAVOUR" ]; then
	source arch/setup.sh
	return
fi
