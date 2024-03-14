
cd ~/projects/oblo_wise

if [ ! -d "build" ]; then
  mkdir "build"
fi

cd build
rm -rf * || true

cmake -DCMAKE_BUILD_TYPE=Debug ..
make -j20
