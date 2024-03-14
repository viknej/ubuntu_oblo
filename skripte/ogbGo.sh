F=${1:-1234} # 4 hex characters as input argument ('1234' is default)
ID=$F$F$F # 12 hex characters
SECURITY=$F$F$F$F # 16 hex characters
PROPERTIES="ogb.properties"

cd ~/projects/oblo_ogb
if [ ! -d "libs" ]; then
  mkdir libs
fi
cd libs
if [ ! -d "oblomessenger" ]; then
  mkdir oblomessenger
fi
cd oblomessenger
ln -s ../../../oblo_omb/libs/oblomessenger/include . || true
ln -s ../../../oblo_omb/libs/oblomessenger/lib . || true
cd ..
if [ ! -d "wisesdk" ]; then
  mkdir wisesdk
fi
cd wisesdk
ln -s ../../../oblo_wise/include . || true
ln -s ../../../oblo_wise/output/lib . || true
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

cd ../bins/cfg

sed -i "s/gtw.serial = 000000000000/gtw.serial = $ID/g" "$PROPERTIES"
sed -i "s/gtw.security = 0000000000000000/gtw.security = $SECURITY/g" "$PROPERTIES"
