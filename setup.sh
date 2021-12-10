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

build() {
	apt update
	apt install -y lsb-release sudo

	pushd v8
	gclient sync
	# for Docker
	sed -i -e 's/${dev_list} snapcraft/${dev_list}/g' build/install-build-deps.sh
	TZ=America/Los_Angeles
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
	echo $TZ > /etc/timezone
	build/install-build-deps.sh
	tools/dev/gm.py x64.release.d8 d8
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

while getopts dubc: OPT
do
	case $OPT in
		d) download
		;;
		u) update
		;;
		b) build
		;;
		c) checkout $OPTARG
		;;
		\?) exit 1
		;;
	esac
done
