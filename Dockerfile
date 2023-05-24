FROM ubuntu:20.04
WORKDIR /work
ENV PATH $PATH:/work/depot_tools:/work/v8/out.gn/x64.release:/work/v8/out.gn/x64.debug

RUN <<EOF
  set -e

  apt update
  apt install -y git curl python3 python-is-python3 lsb-release sudo xz-utils file
  apt clean

  git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

  TZ=America/Los_Angeles
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
EOF

RUN fetch v8

COPY --chmod=755 build.sh /work
COPY --chmod=755 checkout.sh /work

ENV PATH $PATH
