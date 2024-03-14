#!/bin/bash

count=1
git log --no-walk --pretty=format:"commit $count %s" |
while read line; do
  echo "$line"
  count=$((count+1))
done
