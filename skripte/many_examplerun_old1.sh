#!/bin/bash

# Make this script file execuable.
# Copy it into an example wise device folder, for example 'Multioutlet' (oblo_wise/examples/Multioutlet)
# Run it from that folder like this ./many_examples "$PWD"

# The number of devices can be cahanged.
# The MAC address of the first is 123456789000 and last digits increase for each next device.
# Depending on this and the number of devices, payload in /home/{USER}/projects/oblo_gateway_tools/oblo_python_client/obloconfig.json should be updated.

# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "No arguments supplied. Please provide a path."
    exit 1
fi

path=$1
config_path=../cfg/Config.txt
NUM_OF_DEVICES=100

# Navigate to the 'bins' directory in the given path
cd $path/bins || exit

# Iterate over all files in the 'bins' directory
for file in *; do
    # Check if the file is executable
    if [[ -x "$file" ]]; then
        for ((i = 1; i <= NUM_OF_DEVICES; i++)); do
            # Execute the file with '../cfg/Config.txt' as an argument
            ./"$file" ../cfg/Config.txt &

            # Modify MAC address
            sed -i "s/Device.Identifier = 123456789[0-9]\{4\}/Device.Identifier = 123456789$(printf '%04d' $i)/" "$config_path"

            sleep 3
        done
    fi
done

# This enables the script to be killed with 'Ctrl + C'
trap 'killAllProcesses' SIGINT SIGTERM

killAllProcesses() {
    echo "Terminating script..."
    # Kill all background processes that were started in this script
    jobs -p | xargs kill -9 2>/dev/null
    exit 1
}
