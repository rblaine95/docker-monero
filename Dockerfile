FROM quay.io/rblaine95/alpine:v3.12 AS builder

# https://git.alpinelinux.org/aports/tree/testing/monero/APKBUILD
# https://github.com/alpinelinux/aports/blob/master/testing/monero/APKBUILD
ARG MONERO_VERSION=0.17.1.7

WORKDIR /opt

RUN apk update && \
    apk --no-cache upgrade && \
    apk --no-cache add boost-dev cmake zeromq \
        libsodium-dev miniupnpc-dev openssl-dev \
        openpgm-dev rapidjson-dev readline-dev \
        unbound-dev zeromq-dev git build-base && \
    apk --no-cache add --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing cppzmq

RUN git clone --recursive https://github.com/monero-project/monero.git -b v${MONERO_VERSION}

RUN mkdir -p monero/build && cd monero/build && \
    cmake -D STATIC=ON \
          -D ARCH="x86-64" \
          -D BUILD_64=ON \
          -D CMAKE_BUILD_TYPE=release \
          -D BUILD_TAG="linux-x64" \
          .. && \
    make release-static-linux-x86_64

FROM quay.io/rblaine95/alpine:v3.12

ENV PATH=/opt/monero:${PATH}

RUN apk update && \
    apk --no-cache upgrade && \
    apk --no-cache add libgcc \
        boost-chrono boost-filesystem \
        boost-program_options libstdc++ \
        icu-libs boost-regex boost-serialization \
        boost-thread miniupnpc ncurses-terminfo-base \
        ncurses-libs readline libsodium libevent unbound-libs libzmq && \
    addgroup monero && \
    adduser -D -h /home/monero -s /bin/sh -G monero monero && \
    mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero
COPY --from=builder /opt/monero/build/bin/monero* /opt/monero/

USER monero

WORKDIR /home/monero

VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081

ENTRYPOINT ["/opt/monero/monerod"]
