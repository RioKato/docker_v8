#!/bin/sh

set -e

if [ -z "$DEBUG" ]
then
  BUILD_TYPE=release
else
  BUILD_TYPE=debug
fi

cd /work/v8
gclient sync
sed -i -e 's/${dev_list} snapcraft/${dev_list}/g' build/install-build-deps.sh
build/install-build-deps.sh
# tools/dev/gm.py x64.$BUILD_TYPE
tools/dev/v8gen.py x64.$BUILD_TYPE
ninja -C out.gn/x64.$BUILD_TYPE d8
