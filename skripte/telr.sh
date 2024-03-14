#!/usr/bin/env bash

RADISYS_IP=192.168.0.100 # gateway IP
IMAGE_PATH=viktor@192.168.0.101:/home/viktor/Downloads # username, your IP, path to images

# Use expect to handle telnet login
expect -c "
spawn telnet $RADISYS_IP
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
send \"alias pids='echo ohm \\\$(pidof oblomanager) && echo osm \\\$(pidof systemManager) && echo omb \\\$(pidof oblomb) && echo ogb \\\$(pidof gatewayBridge)'\r\"
send \"alias deldbs='rm -rf /userdata/mnt/data/*/*'\r\"
send \"clear\r\"
interact
"
