while true
do
	clear
	cd ~
	stat -c "%n %s" vik.pcap
	cd ~/projects/oblo_sysmgr/bins/data
	stat -c "%n %s" o*
	sleep 1
done