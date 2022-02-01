#!/bin/bash -e


SCRIPT_DIR=$(dirname $(readlink -f $0))
cd $SCRIPT_DIR
export PATH=$SCRIPT_DIR/depot_tools:$PATH
export DEPOT_TOOLS_UPDATE=0

download() {
  apt update
  apt install -y git curl python3

  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  fetch v8
  pushd v8
  git checkout main
  popd
}

update() {
  pushd depot_tools
  git pull
  popd
  pushd v8
  git pull
  popd
}

checkout() {
  COMMIT=$1

  pushd v8
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

  pushd v8
  gclient sync
  docker_conf
  build/install-build-deps.sh
  # tools/dev/gm.py x64.release
  tools/dev/v8gen.py x64.release
  ninja -C out.gn/x64.release d8
  popd
}

rebuild() {
  pushd v8
  ninja -C out.gn/x64.release d8
  popd
}

gen_cdb() {
  pushd v8
  tools/dev/v8gen.py x64.release
  ninja -C out.gn/x64.release d8 -t compdb cc cxx > compile_commands.json
  popd
}

run_docker() {
  IMAGE=$1

  docker run -it --rm -m 8g -v `pwd`:/root $IMAGE
}

while getopts duc:brgi: OPT
do
  case $OPT in
    d) download ;;
    u) update ;;
    c) checkout $OPTARG ;;
    b) build ;;
    r) rebuild ;;
    g) gen_cdb ;;
    i) run_docker $OPTARG ;;
    \?) exit 1 ;;
  esac
done

