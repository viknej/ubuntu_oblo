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
PATH1="/home/viktor/projects"

OHM="oblo_ohm"
OSM="oblo_sysmgr"
OMB="oblo_omb"
OGB="oblo_ogb"
WISE="oblo_wise"
SDK="oblo_sdk"
UTIL="oblo_utility"

cd $PATH1

function pullNewestRepo {
    local num1=$1 num2=$2 repo=$3 tag=$4
    cd $repo

    git checkout master # just in case we are checked out to another branch

    git reset --hard $tag

	LatestPatchSet=$(ssh -p 29418 $USERNAME@gerrit.rt-rk.com gerrit query --current-patch-set --format=JSON change:$num2 | \
    sed '2d' | \
    jq '.currentPatchSet.number' | \
    cut -d "\"" -f 2
    )
        
    git pull ssh://$USERNAME@gerrit.rt-rk.com:29418/$repo refs/changes/$num1/$num2/$LatestPatchSet
    git pull

    cd ..
}

pullNewestRepo 03 58003 $OHM v4.21.0
pullNewestRepo 67 72267 $OSM v1.24.0
pullNewestRepo 34 9734 $OMB v1.24.0
pullNewestRepo 09 62709 $OGB v1.1.0
pullNewestRepo 61 41761 $WISE v2.5.0
pullNewestRepo 90 30290 $SDK v2.3.0
pullNewestRepo 54 52154 $UTIL v1.9.0


# 26 9726 old OSM