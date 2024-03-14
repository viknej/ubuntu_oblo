#!/bin/bash

base_file="Config.txt"
output_dir="configs"

mkdir -p "$output_dir"

for i in {1..3}; do
    output_file="${output_dir}/Config${i}.txt"
    cp "$base_file" "$output_file"
    sed -i "s/Device.Identifier = AAAAAAAAAA[0-9]\{2\}/Device.Identifier = AAAAAAAAAA$(printf '%02d' $i)/" "$output_file"
done
