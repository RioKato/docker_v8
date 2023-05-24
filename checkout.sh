#!/bin/sh

cd /work/v8
COMMIT=$1
git checkout $COMMIT
COMMIT_DATE=$(git show -s -n 1 --format=%ci)

cd /work/depot_tools
git checkout $(git rev-list -n 1 --before="$COMMIT_DATE" main)
