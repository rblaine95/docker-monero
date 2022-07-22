###################
# --- builder --- #
###################
FROM docker.io/alpine:3 AS builder

WORKDIR /opt

RUN apk update \
    && apk upgrade \
    && apk add autoconf \
        automake boost boost-atomic \
        boost-build boost-build-doc boost-chrono \
        boost-container boost-context \
        boost-contract boost-coroutine \
        boost-date_time boost-dev boost-doc \
        boost-fiber boost-filesystem boost-graph \
        boost-iostreams boost-libs boost-locale \
        boost-log boost-log_setup boost-math \
        boost-prg_exec_monitor boost-program_options \
        boost-python3 boost-random boost-regex \
        boost-serialization boost-stacktrace_basic \
        boost-stacktrace_noop boost-static \
        boost-system boost-thread boost-timer \
        boost-type_erasure boost-unit_test_framework \
        boost-wave boost-wserialization \
        ca-certificates cmake curl dev86 \
        doxygen eudev-dev file g++ \
        git graphviz libexecinfo-dev \
        libsodium-dev libtool libusb-dev \
        linux-headers make miniupnpc-dev \
        ncurses-dev openssl-dev \
        pcsc-lite-dev pkgconf \
        protobuf-dev rapidjson-dev \
        readline-dev unbound-dev zeromq-dev

ARG MONERO_VERSION=0.17.3.2
RUN git clone --recursive --depth 1 --shallow-submodules https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

ARG BUILD_THREADS=1
RUN cd monero \
    && case "$(uname -m)" in \
        x86_64) CMAKE_ARCH="x86-64"; CMAKE_BUILD_TAG="linux-x64";; \
        aarch64* | arm64 | armv8*) CMAKE_ARCH="armv8-a"; CMAKE_BUILD_TAG="linux-armv8";; \
        *) echo "Unknown architecture: $(uname -m)" && exit 1;; \
      esac \
    && mkdir -p build/release && cd build/release \
    && cmake -D ARCH=${CMAKE_ARCH} -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG=${CMAKE_BUILD_TAG} ../.. \
    && cd /opt/monero \
    && nice -n 19 ionice -c2 -n7 make -j${BUILD_THREADS} -C build/release


##################
# --- runner --- #
##################
FROM docker.io/alpine:3

ENV PATH=/opt/monero:${PATH}

RUN apk --no-cache --update upgrade \
    && apk --no-cache add curl \
        ca-certificates libexecinfo \
        libsodium ncurses-libs \
        pcsc-lite-libs readline \
        unbound-dev zeromq tini \
    && addgroup monero \
    && adduser -D -h /home/monero -s /bin/sh -G monero monero \
    && mkdir /opt/bitmonero \
    && ln -s /opt/bitmonero /home/monero/.bitmonero \
    && chown -R monero:monero /home/monero/.bitmonero \
    && chown -R monero:monero /opt/bitmonero

COPY --from=builder /opt/monero/build/release/bin/ /opt/monero/

USER monero
WORKDIR /home/monero
VOLUME /opt/bitmonero
EXPOSE 18080 18081

ENTRYPOINT ["tini", "--" ,"/opt/monero/monerod"]
