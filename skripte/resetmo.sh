
cd /home/viktor/projects/oblo_wise/examples/Multioutlet/bins

# Delete all except 'multioutlet'
find . ! -name 'multioutlet' -type f -exec rm -f {} +

sed -i "s/Device.Identifier = 1234567890*/Device.Identifier = 123456789000/" ../cfg/Config.txt

/home/viktor/skripte/brisi.sh