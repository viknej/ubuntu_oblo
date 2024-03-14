# List IP addresses of local devices
sudo  arp-scan -l

# Input GW host ID
echo -e "\n\n\n\nInput GW host ID (the last part of the gateway IP address)\nand hit Enter:"
read hostID

# Telnet to GW
curl "telnet://192.168.1.$hostID" <<EOF

/etc/init.d/dosm stop
killall oblomb
killall oblomanager
sleep 20
cd /mnt/log
rm -rf o* || true
cd /mnt/data/ohm
rm -rf * || true
cd ../osm
rm -rf s* || true
cd ../omb
rm -rf * || true
/etc/init.d/dosm start
EOF