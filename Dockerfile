###################
# --- builder --- #
###################
FROM docker.io/debian:11-slim AS builder

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
        libboost-locale-dev  libboost-program-options-dev libboost-regex-dev \
        libboost-serialization-dev libboost-system-dev \
        libboost-thread-dev python3 ccache doxygen graphviz \
        libevent-dev libnorm-dev

ARG MONERO_VERSION=0.18.0.0
RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

ARG BUILD_THREADS
# Build libexpact - required for libunbound
RUN set -ex && wget https://github.com/libexpat/libexpat/releases/download/R_2_4_8/expat-2.4.8.tar.bz2 && \
    echo "a247a7f6bbb21cf2ca81ea4cbb916bfb9717ca523631675f99b3d4a5678dcd16  expat-2.4.8.tar.bz2" | sha256sum -c && \
    tar -xf expat-2.4.8.tar.bz2 && \
    rm expat-2.4.8.tar.bz2 && \
    cd expat-2.4.8 && \
    ./configure --enable-static --disable-shared --prefix=/usr && \
    make -j${BUILD_THREADS:-$(nproc)} && \
    make -j${BUILD_THREADS:-$(nproc)} install

# Build libunbound
WORKDIR /tmp
RUN set -ex && wget https://www.nlnetlabs.nl/downloads/unbound/unbound-1.16.1.tar.gz && \
    echo "2fe4762abccd564a0738d5d502f57ead273e681e92d50d7fba32d11103174e9a  unbound-1.16.1.tar.gz" | sha256sum -c && \
    tar -xzf unbound-1.16.1.tar.gz && \
    rm unbound-1.16.1.tar.gz && \
    cd unbound-1.16.1 && \
    ./configure --disable-shared \
      --enable-static \
      --without-pyunbound \
      --with-libexpat=/usr \
      --with-ssl=/usr \
      --with-libevent=no \
      --without-pythonodule \
      --disable-flto \
      --with-pthreads \
      --with-libunbound-only \
      --with-pic && \
    make -j${BUILD_THREADS:-$(nproc)} && \
    make -j${BUILD_THREADS:-$(nproc)} install

WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) make -j${BUILD_THREADS:-$(nproc)} release-static-linux-x86_64;; \
      aarch64* | arm64 | armv8*) make -j${BUILD_THREADS:-$(nproc)} release-static-linux-armv8;; \
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
