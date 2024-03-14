# For everything to work, first install jq:
# sudo apt-get install jq
# 
# Change variable names to correspond to your folder names
# USERNAME, PATH1, OHM, OSM, OMB, OGB, WISE, SDK, UTIL
#
# Save script in "home" folder as SCRIPT_NAME.sh
#
# Set the script to be executable:
# Right click on SCRIPT_NAME.sh ->Properties -> Permissions -> Execute: checkbox
#
# Open terminal and run the script
# ./SCRIPT_NAME.sh


USERNAME="viktor"
PATH1="projects"

OHM="oblo_ohm"
WISE="oblo_wise"

cd ~/$PATH1/$OHM

function pullNewestRepo {
    cd ../$3

    git checkout weather_api

    git reset --hard origin/master

	LatestPatchSet=$(ssh -p 29418 $USERNAME@gerrit.rt-rk.com gerrit query --current-patch-set --format=JSON change:$2 | \
    sed '2d' | \
    jq '.currentPatchSet.number' | \
    cut -d "\"" -f 2
    )
        
    git pull ssh://$USERNAME@gerrit.rt-rk.com:29418/$3 refs/changes/$1/$2/$LatestPatchSet
    git pull
}

pullNewestRepo 91 69591 $OHM
pullNewestRepo 20 69420 $WISE
