USERNAME=viktor

function clone_repo () {
	local repo=$1
	git clone "ssh://$USERNAME@gerrit.rt-rk.com:29418/$repo" && scp -p -P 29418 $USERNAME@gerrit.rt-rk.com:hooks/commit-msg "$repo/.git/hooks/"
}

clone_repo oblo_ohm
clone_repo oblo_sysmgr
clone_repo oblo_omb
clone_repo oblo_ogb
clone_repo oblo_wise
clone_repo oblo_sdk
clone_repo oblo_utility
