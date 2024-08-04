#!/usr/bin.env bash

# Clear terminal
clear

# Remove old functions library
rm -f /tmp/functions.sh

# Download common functions library
if ! curl -s -o /tmp/functions.sh https://raw.githubusercontent.com/RFM-Hits/bash-functions/main/common-functions.sh; then
    echo "*** Error: Failed to download common functions library. Check your internet connection."
    exit 1
fi

# Source the functions
source /tmp/functions.sh

# Start Banner
cat << "EOF"
_______________  ___  _   _ _____ _____ _____                  
| ___ \  ___|  \/  | | | | |_   _|_   _/  ___|                 
| |_/ / |_  | .  . | | |_| | | |   | | \ `--.                  
|    /|  _| | |\/| | |  _  | | |   | |  `--. \                 
| |\ \| |   | |  | | | | | |_| |_  | | /\__/ /                 
\_| \_\_|   \_|  |_/ \_| |_/\___/  \_/ \____/                  
  ___  _   _______ _____ _____   _____ _____ ___  _____  _   __
 / _ \| | | |  _  \_   _|  _  | /  ___|_   _/ _ \/  __ \| | / /
/ /_\ \ | | | | | | | | | | | | \ `--.  | |/ /_\ \ /  \/| |/ / 
|  _  | | | | | | | | | | | | |  `--. \ | ||  _  | |    |    \ 
| | | | |_| | |/ / _| |_\ \_/ / /\__/ / | || | | | \__/\| |\  \
\_| |_/\___/|___/  \___/ \___/  \____/  \_/\_| |_/\____/\_| \_/
                                                               
              
******************************************************************
LIQUIDSOAP INSTALLER - RFM HITS - Version 1.0
******************************************************************                                                 
EOF

os_id=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
os_version=$(lsb_release -cs)
os_arch=$(dpkg --print-architecture)

# Configure environment
set_colors
check_privileges privileged
is_linux
is_64bit
set_timezone Europe/Amsterdam


ask_user "DO_UPDATES" "y" "Do you want to update the system before installing Liquidsoap? (y/n)" "y/n"

# OS-specific configurations for Debian Bookworm
if [ "$os_version" == "bookworm" ]; then
  install_packages silent software-properties-common
  apt-add-repository -y non-free
fi

# Update OS
if [ "$DO_UPDATES" == "y" ]; then
  update_os silent
fi