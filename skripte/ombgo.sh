F=${1:-1234} # 4 hex characters as input argument ('1234' is default)
ID=$F$F$F # 12 hex characters
SECURITY=$F$F$F$F # 16 hex characters
PROPERTIES="oblomb.properties"

cd ~/projects/oblo_omb

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

sed -i "s/cloud.oblo.rs/test.oblo.rs/g" "$PROPERTIES"
sed -i "s/gtw.id:000000000000/gtw.id:$ID/g" "$PROPERTIES"
sed -i "s/gtw.sec:0000000000000000/gtw.sec:$SECURITY/g" "$PROPERTIES"
