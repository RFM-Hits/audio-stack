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

# Configure environment
set_colors
check_privileges privileged
is_linux
is_64bit
set_timezone Europe/Amsterdam

