FROM alpine:3.12

# https://git.alpinelinux.org/aports/tree/testing/monero/APKBUILD
# https://github.com/alpinelinux/aports/blob/master/testing/monero/APKBUILD
ARG MONERO_VERSION=0.17.1.3-r0

WORKDIR /opt

RUN apk update && \
    apk --no-cache upgrade && \
    apk --no-cache add --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing monero=${MONERO_VERSION} && \
    addgroup monero && \
    adduser -D -h /home/monero -s /bin/sh -G monero monero && \
    mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero

USER monero

WORKDIR /home/monero

VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081

ENTRYPOINT ["/usr/bin/monerod"]
