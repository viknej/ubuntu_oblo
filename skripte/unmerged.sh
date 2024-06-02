#!/bin/bash

user="viktor"
password="z7s/dfphviFkJfcL82mNlhH4B8CJcVh13HOwTf0Gqw"
base_url="https://gerrit.rt-rk.com/a/changes/"

# Function to perform authenticated curl requests and handle JSON response
get_json() {
    curl -s -u "$user:$password" "$1" | sed '1d' | jq -r "$2"
}

process_unmerged_changes_below_weekly() {
    local change_id=$1
    local repo_name=$2
    local logged_repo_name=false

    while true; do
        # Get hash of parent commit
        local commit_hash=$(get_json "$base_url/$change_id/revisions/current/commit" '.parents[0].commit')
        
        # Break the loop if no more commits are found or if jq returns null
        if [ -z "$commit_hash" ] || [ "$commit_hash" == "null" ]; then
            break
        fi

        # Get change ID from commit hash
        change_id=$(get_json "$base_url/?q=commit:$commit_hash" '.[0]._number')

        # Fetch the status of the current commit
        local current_status=$(get_json "$base_url/$change_id" '.status')

        # Check if the current commit is merged
        if [[ "$current_status" == "MERGED" ]]; then
            break
        fi

        if [[ "$logged_repo_name" == false ]]; then
            logged_repo_name=true
            echo -e "\033[38;5;79m$repo_name\033[0m"
        fi

        latest_patch_set=$(get_json "$base_url/$change_id/detail" '.messages[]._revision_number' | \
            sort -n | tail -1
        )
        
        review_status=$(get_json "$base_url/$change_id/detail?o=ALL_REVISIONS" '
            if .labels["Code-Review"].approved then "+2" 
            elif .labels["Code-Review"].recommended then "+1" 
            elif .labels["Code-Review"].disliked then "-1" 
            elif .labels["Code-Review"].rejected then "-2" 
            else " 0" 
            end'
        )

        commit_name=$(get_json "$base_url/$change_id/revisions/current/commit" '.message' | head -n 1)

        latest_patch_set_color=140
        review_status_color=168
        change_id_color=169
        commit_name_color=108
        if [[ "$review_status" != "+2" && "$review_status" != "+1" ]]; then
            commit_name_color=197
        fi

        echo -e " \033[38;5;${latest_patch_set_color}m$(printf "%2s" "$latest_patch_set")" \
        " \033[38;5;${review_status_color}m$review_status" \
        " \033[38;5;${change_id_color}m$change_id" \
        " \033[38;5;${commit_name_color}m$commit_name\033[0m"
    done

    if [[ "$logged_repo_name" == true ]]; then
        echo ""
    fi
}

echo ""
repos=(
    "58003 OHM"
    "72267 OSM"
    "9734 OMB"
    "62709 OGB"
    "41761 WISE"
    "30290 SDK"
    "52154 UTIL"
)

for repo in "${repos[@]}"; do
    process_unmerged_changes_below_weekly $repo
done
