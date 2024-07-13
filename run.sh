#!/bin/bash

OS_ARCHLINUX="Arch Linux"
OS_ENDEAVOUR="EndeavourOS"
OS_UBUNTU="UBUNTU"

# Check OS
check_os() {
	OS_NAME=$(sed -n 's/^NAME=//p' /etc/os-release | tr -d '"')
	echo "Operating System: $OS_NAME"
}


# Check Run as Root
#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root"
#  exit
#fi

check_os

if [ "$OS_NAME" = "$OS_UBUNTU" ]; then
	source ./ubuntu/setup.sh
	exit
fi

if [ "$OS_NAME" = "$OS_ARCHLINUX" ] || [ "$OS_NAME" = "$OS_ENDEAVOUR" ]; then
	source ./arch/setup.sh
	exit
fi
