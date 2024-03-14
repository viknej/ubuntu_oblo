
#!/bin/bash

BASE_DIR="$HOME/projects/"

declare -A REPOS=(
    ["OHM"]="oblo_ohm"
    ["OSM"]="oblo_sysmgr"
    ["OMB"]="oblo_omb"
    ["SDK"]="oblo_sdk"
    ["UTIL"]="oblo_utility"
    ["WISE"]="oblo_wise"
    ["OGB"]="oblo_ogb"
    ["GWT"]="oblo_gateway_tools"
)

echo

for REPO_NAME in "${!REPOS[@]}"
do
    REPO_DIR="${BASE_DIR}${REPOS[$REPO_NAME]}"
    if [ -d "$REPO_DIR" ] && [ -d "$REPO_DIR/.git" ]; then
        cd "$REPO_DIR"
        STATUS=$(git -c color.status=always status -s)
        BRANCH=$(git branch --show-current)
        if [ -n "$STATUS" ]; then
            echo "$REPO_NAME   $BRANCH:"
            echo "$STATUS"
            echo
        fi
    else
        echo "Repository $REPO_NAME at $REPO_DIR not found or not a Git repo."
        echo
    fi
done
