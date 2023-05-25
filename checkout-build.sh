#!/bin/sh

set -e

if [ -z "$DEBUG" ]
then
  BUILD_TYPE=release
else
  BUILD_TYPE=debug
fi

cd /work/v8
COMMIT=$1
git checkout $COMMIT
COMMIT_DATE=$(git show -s -n 1 --format=%ci)
export DEPOT_TOOLS_UPDATE=0
git clean -ffd

cd /work/depot_tools
git checkout $(git rev-list -n 1 --before="$COMMIT_DATE" main)
git clean -ffd

cd /work/v8
gclient sync -D --force --reset
sed -i -e 's/${dev_list} snapcraft/${dev_list}/g' build/install-build-deps.sh
build/install-build-deps.sh
# tools/dev/gm.py x64.$BUILD_TYPE
tools/dev/v8gen.py x64.$BUILD_TYPE
ninja -C out.gn/x64.$BUILD_TYPE d8

