#!/bin/bash

output_file=/home/viktor/skripte/WeeklyReleaseFormatting/OUTPUT.txt

#Delete OUTPUT.txt if it exists
rm -rf $output_file || true

# Function to convert input text to table format
convert_to_table() {
    local link_number=0  # Initialize a counter

    # Read input line by line
    while IFS= read -r line; do
        # Extract relevant fields using regular expressions
        if [[ $line =~ ([0-9]{2}:[0-9]{2}:[0-9]{2})\ \*\ ([a-z0-9]+)\ -\ (.+)\ \((.+)\)\ \<(.+)\> ]]; then
            ((link_number++))

            commit_message="${BASH_REMATCH[3]}"
            task="${commit_message%%:*}"
            description="${commit_message#*: }"
            developer="${BASH_REMATCH[5]}"

            # Print the formatted table row with numbered link
            echo "|>. $task|${description}|%{color:green}${developer}%|>. \"${link_number}. link\":|"
        fi
    done
}

# Main script execution
{
    # Write header to the file
    cat <<- EOF > $output_file
    
*%{font-size:1.5em;color:#5347c3}2346%*

p(. 08.04.2024.

table{margin-left:2em}.
|=. *4.11.0 images*|=. *Clouds*|=. *doc400*|=. *doc400 + ogb*|=. *voc200*|=. *jco401*|=. *jco4032*|=. *shh600*|
|"*rtrk*":https://redmine.rt-rk.com/projects/oblo/dmsf?folder_id=6059|test.oblo.rs||=. ✓|||||
|/2. "*reliance*":https://redmine.rt-rk.com/projects/oblo/dmsf?folder_id=1126|jiohomeliving.com||=. ✓|=. ✓|=. ✓|=. ✓|=. ✓|
|jiohome.oblo.rs||=. ✓|=. ✓|||=. ✓|
|/2. "*eniwa*":https://redmine.rt-rk.com/projects/oblo/dmsf?folder_id=4818|test.livina.io|=. ✓||||||
|cloud.livina.io|=. ✓||||||

&nbsp;

table{margin-left:2em}.
|=. *Repo*|=. *Task*|=. *Commit*|=. *Developer*|=. *Gerrit*|

|/0=. *OHM*

|/0=. *OSM*

|/0=. *OMB*

|/0=. *OGB*

|/0=. *WISE*

|/0=. *SDK*

|/0=. *UTILITY*

&nbsp;

EOF

    # Call the function and append the output
    convert_to_table < "/home/viktor/skripte/WeeklyReleaseFormatting/input.txt" >> $output_file
} 

echo "Conversion complete. Output saved in OUTPUT.txt"

subl -n $output_file
