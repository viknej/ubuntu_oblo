#!/bin/bash

# Amend commit under top (weekly) commit

git stash

TOP_COMMIT_HASH=$(git rev-parse HEAD)

git reset --hard HEAD^

git stash pop
git add -A
git commit --amend --no-edit

git cherry-pick $TOP_COMMIT_HASH
