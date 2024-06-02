#!/bin/bash

MAC_SUFFIX=${1:-0ec2}

# Run arp-scan and filter the output using awk
IP_ADDRESS=$(sudo arp-scan -l | awk -v mac_suffix="$MAC_SUFFIX" '
    {
        gsub(/:/, "", $2) # Remove colons from the MAC address for comparison
        if (substr($2, length($2) - length(mac_suffix) + 1) == mac_suffix) {
            print $1
            exit
        }
    }
')

# Check if an IP address was found
if [ -z "$IP_ADDRESS" ]; then
    echo "No device found with MAC address suffix $MAC_SUFFIX"
    exit 1
fi

IMAGE_PATH=viktor@192.168.0.101:/home/viktor/Downloads # username, your IP, path to images

# Use expect to handle telnet login
expect -c "
spawn telnet $IP_ADDRESS
expect \"login:\"
send \"root\r\"
expect \"Password:\"
send \"rockchip\r\"
send \"alias ohmtail='tail -f -n200 /userdata/mnt/log/oblomanager.log'\r\"
send \"alias osmtail='tail -f -n200 /userdata/mnt/log/osm.log'\r\"
send \"alias ombtail='tail -f -n200 /userdata/mnt/log/oblomb.log'\r\"
send \"alias ogbtail='tail -f -n200 /userdata/mnt/log/ogb.log'\r\"
send \"alias logs='cd /userdata/mnt/log'\r\"
send \"alias creds='updmngr -n get; updmngr -s get'\r\"
send \"alias versionini='vi /etc/version.ini'\r\"
send \"alias app='scp -o StrictHostKeyChecking=no $IMAGE_PATH/app.tar.gz /tmp/; update.sh /tmp/app.tar.gz'\r\"
send \"alias full='scp -o StrictHostKeyChecking=no $IMAGE_PATH/full.tar.gz /tmp/; update.sh /tmp/full.tar.gz'\r\"
send \"alias ohmprop='vi /userdata/usr/data/ohm/cfg/ohm.properties'\r\"
send \"alias osmprop='vi /userdata/usr/data/osm/cfg/osm.properties'\r\"
send \"alias ombprop='vi /userdata/usr/data/omb/cfg/oblomb.properties'\r\"
send \"alias ogbprop='vi /userdata/usr/data/ogb/cfg/ogb.properties'\r\"
send \"alias dosmstop='/etc/init.d/S99dosm stop'\r\"
send \"alias dosmstart='/etc/init.d/S99dosm start'\r\"
send \"alias killapps='killall -9 oblomb oblomanager gatewayBridge'\r\"
send \"alias pids='echo ohm \\\$(pidof oblomanager) &&
                   echo osm \\\$(pidof systemManager) &&
                   echo omb \\\$(pidof oblomb) &&
                   echo ogb \\\$(pidof gatewayBridge)'\r\"
send \"alias deldbs='rm -rf /userdata/mnt/data/*/*'\r\"
send \"alias ll='ls -la'\r\"
send \"alias aliases='clear &&
                      echo \\\"----------------------------------------------\\\" &&
                      echo \\\"             ALIASES\\\" &&
                      echo \\\"----------------------------------------------\\\" &&
                      echo \\\"ohmtail    = tail ohm log\\\" &&
                      echo \\\"osmtail    = tail osm log\\\" &&
                      echo \\\"ombtail    = tail omb log\\\" &&
                      echo \\\"ogbtail    = tail ogb log\\\" &&
                      echo \\\" \\\" &&
                      echo \\\"ohmprop    = edit ohm.properties\\\" &&
                      echo \\\"osmprop    = edit osm.properties\\\" &&
                      echo \\\"ombprop    = edit oblomb.properties\\\" &&
                      echo \\\"ogbprop    = edit ogb.properties\\\" &&
                      echo \\\" \\\" &&
                      echo \\\"creds      = print GW serial and security code\\\" &&
                      echo \\\"logs       = navigate to logs folder\\\" &&
                      echo \\\"pids       = PIDs of ohm, osm, omb, ogb\\\" &&
                      echo \\\"versionini = edit version.ini\\\" &&
                      echo \\\" \\\" &&
                      echo \\\"app        = run app update\\\" &&
                      echo \\\"full       = run full update\\\" &&
                      echo \\\"deldbs     = delete all databases\\\" &&
                      echo \\\"dosmstart  = start dosm\\\" &&
                      echo \\\"dosmstop   = stop dosm\\\" &&
                      echo \\\"killapps   = kill omb, ohm, ogb\\\" &&
                      echo \\\" \\\" &&
                      echo \\\" aliases   = list all aliases\\\" &&
                      echo \\\" cls       = clear screen\\\" &&
                      echo \\\" ll        = ls -la (detailed folder content)\\\" &&
                      echo \\\" q         = exit telnet\\\" &&
                      echo \\\"----------------------------------------------\\\"'\r\"
send \"alias cls='clear'\r\"
send \"alias q='exit'\r\"
send \"clear\r\"
send \"aliases\r\"
interact
"
