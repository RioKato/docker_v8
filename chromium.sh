#!/bin/bash -e


SCRIPT_DIR=$(dirname $(readlink -f $0))
cd $SCRIPT_DIR
export PATH=$SCRIPT_DIR/depot_tools:$PATH
export DEPOT_TOOLS_UPDATE=0

if [ -z "$DEBUG" ]
then
  BUILD_TYPE=release
else
  BUILD_TYPE=debug
fi

download() {
  apt update
  apt install -y git curl python3

  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  mkdir chromium
  pushd chromium
  fetch --nohooks chromium
  pushd src
  git checkout main
  popd
  popd
}

pull() {
  pushd depot_tools
  git pull
  popd
  pushd chromium/src
  git pull
  popd
}

checkout() {
  COMMIT=$1

  pushd chromium/src
  git checkout $COMMIT
  COMMIT_DATE=$(git show -s -n 1 --format=%ci)
  popd
  pushd depot_tools
  git checkout $(git rev-list -n 1 --before="$COMMIT_DATE" main)
  popd
}

docker_conf() {
  sed -i -e 's/${dev_list} snapcraft/${dev_list}/g' build/install-build-deps.sh
  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
}

build() {
  apt update
  apt install -y lsb-release sudo

  pushd chromium/src
  docker_conf
  build/install-build-deps.sh
  gclient runhooks
  gn gen out/Default
  autoninja -C out/Default chrome
  popd
}

rebuild() {
  pushd chromium/src
  autoninja -C out/Default chrome
  popd
}

cdb() {
  pushd chromium/src
  autoninja -C out/Default chrome -t compdb cc cxx > compile_commands.json
  popd
}

run_docker() {
  IMAGE=$1

  docker run -it --rm -m 8g -v `pwd`:/root $IMAGE
}

while getopts dpc:brgi: OPT
do
  case $OPT in
    d) download ;;
    u) pull ;;
    c) checkout $OPTARG ;;
    b) build ;;
    r) rebuild ;;
    g) cdb ;;
    i) run_docker $OPTARG ;;
    \?) exit 1 ;;
  esac
done

