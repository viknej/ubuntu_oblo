#!/bin/bash

#!/bin/bash

TARGET_DIR=~/projects/oblo_wise/examples

cd "$TARGET_DIR" || { echo "Failed to navigate to $TARGET_DIR."; exit 1; }

devices=()

for d in */ ; do
    devices+=("${d%/}")
done

if [ ${#devices[@]} -eq 0 ]; then
    echo "No devices found in $TARGET_DIR."
    exit 1
fi

echo -e "\nBuild Wise Example device:\n"
for i in "${!devices[@]}"; do
    echo "$((i+1)). ${devices[i]}"
done
echo ""

read -p "Select device number: " deviceNumber

if [[ $deviceNumber -lt 1 ]] || [[ $deviceNumber -gt ${#devices[@]} ]]; then
    echo "Invalid number. Try between 1 and ${#devices[@]}."
    exit 1
fi

device=${devices[$((deviceNumber - 1))]}

cd "$device"

rm -rf bins || true
mkdir -p libs/wisesdk build

cd libs/wisesdk
ln -sf ../../../../output/lib .
ln -sf ../../../../include .

cd ../../build
rm -rf * || true
cmake ..
make -j20
