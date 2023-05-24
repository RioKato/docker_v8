FROM ubuntu:22.04
WORKDIR /work
ENV PATH $PATH:/work/depot_tools

RUN <<EOF
  set -e

  apt update
  apt install -y git curl python3 lsb-release sudo xz-utils file
  apt clean

  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
EOF

RUN <<EOF
  set -e

  fetch v8
EOF

COPY --chmod=755 build.sh /work
COPY --chmod=755 checkout.sh /work

ENV PATH $PATH:/work/v8/out.gn/x64.release:/work/v8/out.gn/x64.debug
