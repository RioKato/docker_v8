FROM ubuntu:20.04
ARG COMMIT

WORKDIR /work
ENV PATH $PATH:/work/depot_tools

RUN <<EOF
  set -e

  apt update
  apt install -y git curl python3 python-is-python3 lsb-release sudo xz-utils file
  apt clean

  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
EOF

RUN <<EOF
  set -e

  cd /work
  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
  fetch v8

  if [ -n "$COMMIT" ]
  then
    cd /work/v8
    git checkout $COMMIT
    COMMIT_DATE=$(git show -s -n 1 --format=%ci)
    export DEPOT_TOOLS_UPDATE=0
    git clean -ffd

    cd /work/depot_tools
    git checkout $(git rev-list -n 1 --before="$COMMIT_DATE" main)
    git clean -ffd
  fi

  cd /work/v8

  if [ -n "$COMMIT" ]
  then
    gclient sync -D --force --reset
  else
    gclient sync
  fi

  sed -i -e 's/${dev_list} snapcraft/${dev_list}/g' build/install-build-deps.sh
  echo y | build/install-build-deps.sh
  tools/dev/v8gen.py x64.release
  ninja -C out.gn/x64.release d8

  tools/dev/v8gen.py x64.debug
  ninja -C out.gn/x64.debug d8
EOF
