F=${1:-1234} # 4 hex characters as input argument ('1234' is default)
ID=$F$F$F # 12 hex characters
SECURITY=$F$F$F$F # 16 hex characters
PROPERTIES="osm.properties"
VERSION_INI="version.ini"

cd ~/projects/oblo_sysmgr
if [ ! -d "libs" ]; then
  mkdir libs
fi
cd libs
if [ ! -d "oblo_messenger" ]; then
  mkdir oblo_messenger
fi
cd oblo_messenger
ln -s ../../../oblo_omb/libs/oblomessenger/include .
ln -s ../../../oblo_omb/libs/oblomessenger/lib .
cd ../..

rm -rf bins || true

if [ ! -d "build" ]; then
  mkdir "build"
fi

cd build
rm -rf * || true

cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j20
make install

cd ../bins
mkdir data

cd cfg

sed -i "s/gtw.serial = 000000000000/gtw.serial = $ID/g" "$PROPERTIES"
sed -i "s/gtw.security = 0000000000000000/gtw.security = $SECURITY/g" "$PROPERTIES"

sed -i "s/version:1.0.0/version:4.8.0/g" "$VERSION_INI"
sed -i "s/ohm:1.0.0/ohm:4.19.2/g" "$VERSION_INI"
sed -i "s/osm:1.0.0/osm:1.22.0/g" "$VERSION_INI"
sed -i "s/omb:1.0.0/omb:1.22.1/g" "$VERSION_INI"