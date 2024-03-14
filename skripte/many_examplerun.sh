#!/bin/bash

# Make this script file execuable.
# Copy it into an example wise device folder, for example 'Multioutlet' (oblo_wise/examples/Multioutlet)
# Run it from that folder like this ./many_examples "$PWD"

# The number of devices can be cahanged (default is 100).
# Each device is called with a different Config.txt file (Config1.txt, Config2.txt ... Config100.txt)
# Depending on this and the number of devices, payload in /home/{USER}/projects/oblo_gateway_tools/oblo_python_client/obloconfig.json should be updated.

# Check if an argument is passed
if [ $# -eq 0 ]; then
    echo "No arguments supplied. Please provide a path."
    exit 1
fi

path=$1
NUM_OF_DEVICES=100

# Navigate to the 'bins' directory in the given path
cd $path/bins || exit

# Iterate over all files in the 'bins' directory
for file in *; do
    # Check if the file is executable
    if [[ -x "$file" ]]; then
        for ((i = 0; i < NUM_OF_DEVICES; i++)); do
            sleep 9
            
            # Execute the file with '../cfg/Config$i.txt' as an argument
            ./"$file" ../cfg/configs/Config$i.txt &
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