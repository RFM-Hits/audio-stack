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

