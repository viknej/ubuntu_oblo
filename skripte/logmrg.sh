#!/bin/bash

# Run this script in the folder where logs.zip is.
# If the .zip with logs is not named 'logs', rename it to that.
# Run it with "$PWD" argument

if [ $# -eq 0 ]; then
    echo "No arguments supplied. Please provide a path."
    exit 1
fi

path=$1
cd "$path"

unzip logs.zip log/* -d logs
cd logs
mv log/* .
rmdir log
rm perm* upd*

# Use a wildcard to find all .gz files, then extract unique prefixes
# This assumes prefixes end before the first dot and filenames are in 'prefix.something.gz' format
declare -A prefixes  # Associative array to hold unique prefixes

for file in *.gz; do
    # Extract the prefix by cutting the filename at the first dot
    prefix="${file%%.*}"
    prefixes["$prefix"]=1  # Store the prefix as a key, making it unique
done

# Iterate over the unique prefixes and perform the merge operation for each
for prefix in "${!prefixes[@]}"; do
    output_file="${prefix}_mrg.log"
    gz_files=($(ls "${prefix}"*.gz | sort -V -r))

    > "$output_file"  # Create or truncate the output file

    for gz_file in "${gz_files[@]}"; do
        if gzip -d "$gz_file"; then  # Check if gzip successfully decompresses the file
            base_name="${gz_file%.gz}"  # Remove the .gz extension to get the base name
            cat "$base_name" >> "$output_file"  # Append the content to the output file
            rm "$base_name"  # Remove the decompressed file
        fi
    done

    # Append the final log file if it exists and remove it
    if [ -f "${prefix}.log" ]; then
        cat "${prefix}.log" >> "$output_file"
        rm "${prefix}.log"
    fi
done
