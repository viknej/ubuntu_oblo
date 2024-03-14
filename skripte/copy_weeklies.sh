#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo -e "\nNo arguments!\nProvide a weekly number like 2409"
    exit 1
fi

week=$1
user=viktor
folder=Downloads

expect -c "
spawn ssh $user@mcs12
expect \"$user@mcs12:~\"
send \"rm -rf w*.txt || true\r\"
send \"sudo find /var/lib/jenkins/jobs -type f -name '*-BETA$week*' > w$week.txt\r\"
expect \"\\[sudo\\] password for $user:\"
send \"$MY_PASSWORD\r\"
expect \"$user@mcs12:~\"
send \"exit\r\"
"

# Copy txt file with file paths to my computer
scp mcs12:/home/$user/w$week.txt /home/$user/$folder

awk -v user="$user" -v week="$week" -v folder="$folder" '!/(\.zip|\.io\.tar\.gz|OGB\.tar\.gz)$/ {cmd="scp mcs12:\"" $0 "\" /home/" user "/" folder "/"; system(cmd)}' "/home/$user/$folder/w$week.txt"

# Replace ':' with ' ' (colons with spaces)
find /home/$user/$folder/ -type f -name '*:*' | while read -r filepath; do
    # Generate new filename by replacing colons with spaces
    newname=$(echo "$filepath" | sed 's/:/ /g')
    # Rename the file
    mv "$filepath" "$newname"
done

rm /home/$user/$folder/w$week.txt