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

# Install Liquidsoap
install_packages liquidsoap liquidsoap-plugin-all fdkaac libfdkaac-ocaml-dynlink
    if [ $? -ne 0 ]; then
        echo "*** Error: Failed to install Liquidsoap. Exiting."
        exit 1
    fi
    if [ $? -eq 0 ]; then
        echo "Liquidsoap has been installed successfully."
    fi
    else
        echo "Liquidsoap is already installed."
    fi

ask_user "AUDIO_FALLBACK_URL" "https://raw.githubusercontent.com/RFM-Hits/audio-stack/main/fallback.ogg" "Enter the URL of the audio file to play when the stream is down:" "str"
ask_user "LIQUIDSOAP_CONFIG_URL" "https://raw.githubusercontent.com/RFM-Hits/audio-stack/main/radio.liq" "Enter the URL of the Liquidsoap configuration file:" "str"

# Download configuration and sample files
echo -e "${BLUE}►► Downloading files...${NC}"
curl -sLo  /var/audio/fallback.ogg "$AUDIO_FALLBACK_URL"
curl -sLo  /etc/liquidsoap/radio.liq "$LIQUIDSOAP_CONFIG_URL"

ask_user "LIQUIDSOAP_SERVICE_URL" "https://raw.githubusercontent.com/RFM-Hits/audio-stack/main/liquidsoap.service" "Enter the URL of the Liquidsoap service file:" "str"

# Liquidsoap service installation
echo -e "${BLUE}►► Setting up Liquidsoap service${NC}"
rm -f /etc/systemd/system/liquidsoap.service
curl -sLo  /etc/systemd/system/liquidsoap.service "$LIQUIDSOAP_SERVICE_URL"
systemctl daemon-reload
if ! systemctl is-enabled liquidsoap.service; then
  systemctl enable liquidsoap.service
fi

# Prompt the user for input.
# If the user doesn't provide a value, the default value is assigned.
# Parameters:
# $1 - The variable name (will be all caps)
# $2 - The default value for the variable
# $3 - The prompt to display to the user
# $4 - (Optional) The type of the variable (y/n, num, str, email, host). Default is str.
# Example:
# ask_user "MY_NUM" "1" "Please enter a number" "num"
function ask_user {
  local var_name="$1"
  local default_value="$2"
  local prompt="$3"
  local var_type="${4:-str}"

  local input

  while true; do
    read -p "${prompt} [default: ${default_value}]: " input
    input="${input:-$default_value}"

    case $var_type in
      'y/n')
        if [[ "$input" =~ ^(y|n)$ ]]; then
          break
        else
          echo "Invalid input. Please enter y or n."
        fi
        ;;
      'num')
        if [[ "$input" =~ ^[0-9]+$ ]]; then
          break
        else
          echo "Invalid input. Please enter a number."
        fi
        ;;
      'str')
        if [[ -n "$input" ]]; then
          break
        else
          echo "Invalid input. Please enter a string."
        fi
        ;;
      'email')
        if [[ "$input" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
          break
        else
          echo "Invalid input. Please enter a valid e-mail address."
        fi
        ;;
      'host')
        if [[ "$input" =~ ^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$ ]]; then
          break
        else
          echo "Invalid input. Please enter a valid hostname."
        fi
        ;;  
      *)
        echo "Unknown validation type: $var_type"
        return 1
        ;;
    esac
  done

  eval "$var_name=\"$input\""
