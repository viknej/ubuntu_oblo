#!/usr/bin/env bash

# Use expect to handle telnet login
expect -c "
spawn telnet 192.168.0.105
expect \"login:\"
send \"root\r\"
expect \"Password:\"
send \"rockchip\r\"


send \"/etc/init.d/S99dosm stop\r\"
sleep 5

send \"killall -9 oblomb\r\"
send \"killall -9 oblomanager\r\"
send \"killall -9 gatewayBridge\r\"
sleep 20
send \"cd /userdata/mnt/log\r\"
send \"rm -rf o* || true\r\"
send \"cd ../data/ohm\r\"
send \"rm -rf * || true\r\"
send \"cd ../osm\r\"
send \"rm -rf s* || true\r\"
send \"cd ../omb\r\"
send \"rm -rf * || true\r\"
send \"cd ../ogb\r\"
send \"rm -rf * || true\r\"
send \"/etc/init.d/S99dosm start\r\"
send \"exit\r\"
expect eof
"