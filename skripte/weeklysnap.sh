#!/bin/bash

# Gerrit server base URL
GERRIT_BASE_URL="https://gerrit.rt-rk.com"

# Authentication info if needed, e.g., username:password
# Update with your actual authentication or remove if not needed
AUTH="viktor:Sharku18vn@firma"

# Output file for commit details
OUTPUT_FILE="commit_details.txt"

# Declare an associative array for repositories and their start commits
declare -A REPOS_START_COMMITS
REPOS_START_COMMITS["oblo_ohm"]="58003"
REPOS_START_COMMITS["oblo_sysmgr"]="9726"

# Loop through the associative array
for REPO in "${!REPOS_START_COMMITS[@]}"; do
    START_COMMIT=${REPOS_START_COMMITS[$REPO]}
    echo "Fetching commits for repository: $REPO starting from commit $START_COMMIT" >> "$OUTPUT_FILE"
    
    # Initially set to fetch the first batch of commits
    MORE_CHANGES=true
    SKIP=0

    while $MORE_CHANGES; do
        # Fetch commits using Gerrit REST API, limited to a batch of 25 for each call
        COMMITS=$(curl -s --user $AUTH "$GERRIT_BASE_URL/a/changes/?q=project:$REPO+AND+($START_COMMIT..)+status:merged&o=CURRENT_REVISION&n=25&S=$SKIP")

        # Check if any commit is returned
        if [ -z "$COMMITS" ]; then
            MORE_CHANGES=false
            break
        fi

        # Parse the commits and look for the first merged commit
        for COMMIT in $(echo "$COMMITS" | jq -r '.[] | select(.status == "MERGED") | "\(.current_revision)"'); do
            # Write the merged commit to the output file
            echo "$COMMIT" >> "$OUTPUT_FILE"
            # Stop after finding the first merged commit
            MORE_CHANGES=false
            break 2 # Break out of both the for loop and the while loop
        done

        # Prepare for the next batch
        SKIP=$((SKIP + 25))
    done

    echo "---------------------------------" >> "$OUTPUT_FILE"
done

echo "Commit details fetched successfully."
