#!/bin/bash

GATEWAY_MAC_SUFFIX=${1:-0ec1}
MY_PC_MAC="7c:4d:8f:ad:0e:a6"
PC_USER="viktor"

# Extract Gateway IP from the last 4 digits of its MAC
GATEWAY_IP=$(sudo arp-scan -l | awk -v mac_suffix="$GATEWAY_MAC_SUFFIX" '
    {
        gsub(/:/, "", $2) # Remove colons from the MAC address for comparison
        if (substr($2, length($2) - length(mac_suffix) + 1) == mac_suffix) {
            print $1
            exit
        }
    }'
)

if [ -z "$GATEWAY_IP" ]; then
    echo "No device found with MAC address suffix $GATEWAY_MAC_SUFFIX"
    exit 1
fi

# Exctract my pc IP from its MAC
MY_PC_IP=$(sudo arp-scan -l | awk -v mac="$MY_PC_MAC" '
    {
        gsub(/:/, "", $2) # Remove colons from the MAC address for comparison
        gsub(/:/, "", mac) # Remove colons from the input MAC address for comparison
        if ($2 == mac) {
            print $1
            exit
        }
    }'
)

if [ -z "$MY_PC_IP" ]; then
    echo "No device found with MAC address $MY_PC_MAC"
    exit 1
fi

expect -c "
spawn telnet $GATEWAY_IP
send \"pass=printenv MY_PASSWORD\r\"
send \"export PLATFORM_NAME=\\\"doc400\\\"\r\"
send \"scp -o StrictHostKeyChecking=no $PC_USER@$MY_PC_IP:/home/$PC_USER/skripte/aliases.sh /tmp/;\
       source /tmp/aliases.sh\r\"
expect \"$PC_USER@$MY_PC_IP's password:\"
send \"$MY_PASSWORD\r\"
interact
"
