###################
# --- builder --- #
###################
FROM ghcr.io/rblaine95/debian:10-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y build-essential \
        cmake pkg-config libboost-all-dev \
        libssl-dev libzmq3-dev libunbound-dev \
        libsodium-dev libunwind8-dev liblzma-dev \
        libreadline6-dev libldns-dev libexpat1-dev \
        doxygen graphviz libpgm-dev qttools5-dev-tools \
        libhidapi-dev libusb-1.0-0-dev libprotobuf-dev \
        protobuf-compiler libudev-dev git && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1

ARG MONERO_VERSION=0.17.3.0
RUN git clone --recursive https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

ARG BUILD_THREADS=1
RUN cd monero && \
    case "$(uname -m)" in \
      x86_64) make -j${BUILD_THREADS} release-static-linux-x86_64;; \
      aarch64* | arm64 | armv8*) make -j${BUILD_THREADS} release-static-linux-armv8;; \
      armv7*) make -j${BUILD_THREADS} release-static-linux-armv7;; \
      armv6*) make -j${BUILD_THREADS} release-static-linux-armv6;; \
      *) echo "Unknown architecture: $(uname -m)" && exit 1;; \
    esac

##################
# --- runner --- #
##################
FROM ghcr.io/rblaine95/debian:11-slim

ENV PATH=/opt/monero:${PATH}

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tini ca-certificates libkrb5-dev && \
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
