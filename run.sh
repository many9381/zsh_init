#!/bin/bash

OS_ARCHLINUX="Arch Linux"
OS_ENDEAVOUR="EndeavourOS"
OS_UBUNTU="Ubuntu"

source scripts/common/common.sh

if ! check_run_as_root; then
	echo "Please run as root"
	exit
fi

# Check OS
OS_NAME=$(sed -n 's/^NAME=//p' /etc/os-release | tr -d '"')
echo "Operating System: $OS_NAME"

if [ "$OS_NAME" = "$OS_UBUNTU" ]; then
	source ubuntu/setup.sh
	exit
fi

if [ "$OS_NAME" = "$OS_ARCHLINUX" ] || [ "$OS_NAME" = "$OS_ENDEAVOUR" ]; then
	source arch/setup.sh
	exit
fi
