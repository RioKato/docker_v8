FROM --platform=linux/amd64 ubuntu:20.04
WORKDIR /root
COPY setup.sh .
RUN ./setup.sh -d
