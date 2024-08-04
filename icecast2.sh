#!/usr/bin/env bash

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
ICECAST 2 INSTALLER - RFM HITS - Version 1.0
******************************************************************                                                 
EOF

# Configure environment
set_colors
check_privileges privileged
is_linux
is_64bit
set_timezone Europe/Amsterdam

# Collect input from user
ask_user "HOSTNAME" "localhost" "Enter the hostname or IP address of the server" "str"
ask_user "SOURCEPASS" "hackme" "Specify the source and relay password" "str"
ask_user "ADMINPASS" "hackme" "Specify the admin password" "str"
ask_user "LOCATED" "Earth" "Where is this server located (visible on admin pages)?" "str"
ask_user "ADMINMAIL" "root@localhost.local" "What's the admins e-mail (visible on admin pages and for let's encrypt)?" "email"
ask_user "PORT" "80" "Specify the port" "num"
ask_user "SSL" "n" "Do you want Let's Encrypt to get a certificate for this server? (y/n)" "y/n"

# Set environment variables
export DEBIAN_FRONTEND=noninteractive

# Update and install packages
update_os silent
install_packages icecast2 certbot

# Generate Icecast2 configuration
ICECAST_XML="/etc/icecast2/icecast.xml"
cat <<EOF > "$ICECAST_XML"
<icecast>
    <location>$LOCATED</location>
    <admin>$ADMINMAIL</admin>
    <hostname>$HOSTNAME</hostname>

    <limits>
        <clients>10000</clients>
        <sources>30</sources>
        <burst-size>65535</burst-size>
    </limits>

    <authentication>
        <source-password>$SOURCEPASS</source-password>
        <relay-password>$SOURCEPASS</relay-password>
        <admin-user>admin</admin-user>
        <admin-password>$ADMINPASS</admin-password>
    </authentication>

    <listen-socket>
        <port>$PORT</port>
    </listen-socket>

    <http-headers>
        <header name="Access-Control-Allow-Origin" value="*" />
        <header name="X-Robots-Tag" value="noindex" />
    </http-headers>

    <paths>
        <basedir>/usr/share/icecast2</basedir>
        <logdir>/var/log/icecast2</logdir>
        <webroot>/usr/share/icecast2/web</webroot>
        <adminroot>/usr/share/icecast2/admin</adminroot>
        <alias source="/" dest="/status.xsl"/>
    </paths>

    <logging>
        <accesslog>access.log</accesslog>
        <errorlog>error.log</errorlog>
        <loglevel>3</loglevel>
        <logsize>10000</logsize>
    </logging>
</icecast>
EOF

# Set capabilities
setcap 'CAP_NET_BIND_SERVICE=+eip' /usr/bin/icecast2

# Reload & restart Icecast2
systemctl enable icecast2
systemctl daemon-reload
systemctl restart icecast2


# SSL configuration
if [ "$SSL" = "y" ] && [ "$PORT" = "80" ]; then
  # Run Certbot to obtain SSL certificate
  echo -e "${BLUE}►► Running Certbot to obtain SSL certificate...${NC}"
  certbot --text --agree-tos --email "$ADMINMAIL" --noninteractive --no-eff-email --webroot --webroot-path="/usr/share/icecast2/web" -d "$HOSTNAME" --deploy-hook "cat /etc/letsencrypt/live/$HOSTNAME/fullchain.pem /etc/letsencrypt/live/$HOSTNAME/privkey.pem > /usr/share/icecast2/icecast.pem && systemctl restart icecast2" certonly

  # Check if Certbot was successful
  if [ -f "/usr/share/icecast2/icecast.pem" ]; then
    # Update icecast.xml with SSL settings
    sed -i "/<paths>/a \
    \    <ssl-certificate>/usr/share/icecast2/icecast.pem</ssl-certificate>" "$ICECAST_XML"
    
    sed -i "/<\/listen-socket>/a \
    <listen-socket>\n\
        <port>443</port>\n\
        <ssl>1</ssl>\n\
    </listen-socket>" "$ICECAST_XML"

    # Restart Icecast to apply new configuration
    echo -e "${BLUE}►► Restarting Icecast with SSL support${NC}"
    systemctl restart icecast2
  else
    echo -e "${YELLOW} !! SSL certificate acquisition failed. Icecast will continue running on port ${PORT}.${NC}"
  fi
else
  if [ "$SSL" = "y" ]; then
    echo -e "${YELLOW} !! SSL setup is only possible when Icecast is running on port 80. You entered port ${PORT}. Skipping SSL configuration.${NC}"
  fi
fi


