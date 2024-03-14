#!/bin/bash

#!/bin/bash

# This enables the script to be killed with 'Ctrl + C'
trap 'killAllProcesses' SIGINT SIGTERM

killAllProcesses() {
    echo "Terminating script..."
    # Kill all background processes that were started in this script
    jobs -p | xargs kill -9 2>/dev/null
    exit 1
}

# ... rest of your script ...


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

NUM_OF_DEVICES=50

# Assign the path argument to a variable
path=$1

# Navigate to the 'bins' directory in the given path
cd $path/bins || exit

# Iterate over all files in the 'bins' directory
for file in *; do
    # Check if the file is executable
    if [[ -x "$file" ]]; then
        # Execute the file with '../cfg/Config.txt' as argument
        ./"$file" ../cfg/Config.txt &

        for ((i = 1; i < NUM_OF_DEVICES; i++)); do
            sleep 3
            # Modify MAC address
            if [ "$i" -le 9 ]; then
                sed -i "s/Device.Identifier = 12345678900$((i - 1))/Device.Identifier = 12345678900$i/" ../cfg/Config.txt
            elif [ "$i" -eq 10 ]; then
                sed -i "s/Device.Identifier = 12345678900$((i - 1))/Device.Identifier = 1234567890$i/" ../cfg/Config.txt
            else
                sed -i "s/Device.Identifier = 1234567890$((i - 1))/Device.Identifier = 1234567890$i/" ../cfg/Config.txt
            fi
            # Execute the file with '../cfg/Config.txt' as an argument
            ./"$file" ../cfg/Config.txt &
        done

    fi
done
