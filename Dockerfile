###################
# --- builder --- #
###################
FROM docker.io/debian:10-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget git build-essential \
        automake autotools-dev bsdmainutils \
        ca-certificates curl libtool gperf \
        cmake pkg-config libssl-dev libzmq3-dev \
        libunbound-dev libsodium-dev libunwind8-dev \
        liblzma-dev libreadline6-dev libldns-dev libexpat1-dev \
        libpgm-dev qttools5-dev-tools libhidapi-dev \
        libusb-1.0-0-dev libprotobuf-dev protobuf-compiler \
        libudev-dev libboost-chrono-dev libboost-container-dev \
        libboost-date-time-dev libboost-filesystem-dev \
        libboost-locale-dev libboost-program-options-dev libboost-regex-dev \
        libboost-serialization-dev libboost-system-dev \
        libboost-thread-dev python3 ccache doxygen graphviz \
        libevent-dev libnorm-dev

ARG MONERO_VERSION=0.18.1.0
RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

ARG BUILD_THREADS

WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) make -j${BUILD_THREADS:-$(nproc)} release-static-linux-x86_64;; \
      aarch64* | arm64 | armv8*) make -j${BUILD_THREADS:-$(nproc)} release-static-linux-armv8;; \
      armv7*) make -j${BUILD_THREADS:-$(nproc)} release-static-linux-armv7;; \
      *) echo "Unexpected architecture: $(uname -m)" && exit 1;; \
    esac

##################
# --- runner --- #
##################
FROM docker.io/debian:11-slim

ENV PATH=/opt/monero:${PATH}

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tini libkrb5-dev  \
      curl ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt && \
    useradd -ms /bin/bash monero && \
    mkdir /opt/bitmonero && \
    ln -s /opt/bitmonero /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero && \
    chown -R monero:monero /opt/bitmonero

COPY --from=builder /opt/monero/build/Linux/_no_branch_/release/bin/* /opt/monero/

USER monero
WORKDIR /home/monero
VOLUME /opt/bitmonero
EXPOSE 18080 18081

ENTRYPOINT ["tini", "--" ,"/opt/monero/monerod"]
