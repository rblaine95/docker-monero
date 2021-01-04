FROM ghcr.io/rblaine95/debian:10-slim AS builder

# https://git.alpinelinux.org/aports/tree/testing/monero/APKBUILD
# https://github.com/alpinelinux/aports/blob/master/testing/monero/APKBUILD
ARG MONERO_VERSION=0.17.1.8

WORKDIR /opt

RUN apt update && \
    apt upgrade -y && \
    apt install -y build-essential \
        cmake pkg-config libboost-all-dev \
        libssl-dev libzmq3-dev libunbound-dev \
        libsodium-dev libunwind8-dev liblzma-dev \
        libreadline6-dev libldns-dev libexpat1-dev \
        doxygen graphviz libpgm-dev qttools5-dev-tools \
        libhidapi-dev libusb-1.0-0-dev libprotobuf-dev \
        protobuf-compiler libudev-dev git && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN git clone --recursive https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

RUN cd monero && \
    make -j2 release-static-linux-x86_64

FROM ghcr.io/rblaine95/debian:10-slim

ENV PATH=/opt/monero:${PATH}

RUN apt update && \
    apt upgrade -y && \
    apt install -y ca-certificates libkrb5-dev && \
    apt clean && \
    apt autoremove -y && \
    rm -rf /var/lib/apt && \
    useradd -ms /bin/bash monero && \
    mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero
COPY --from=builder /opt/monero/build/Linux/_no_branch_/release/bin/* /opt/monero/

USER monero

WORKDIR /home/monero

VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081

LABEL org.opencontainers.image.source https://github.com/rblaine95/docker_monero

ENTRYPOINT ["/opt/monero/monerod"]
