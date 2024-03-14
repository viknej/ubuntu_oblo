
clear

cd ~/projects/oblo_ohm/bins/data
rm -rf * || true
cd ~/projects/oblo_sysmgr/bins/data
rm -rf * || true
cd ~/projects/oblo_omb/bins/data
rm -rf * || true

sudo truncate -s 0 ~/vik.pcap

sudo tcpdump -s 0 dst 192.168.242.125 -w vik.pcap