###################
# --- builder --- #
###################
FROM docker.io/debian:11-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      wget ca-certificates bzip2

ARG MONERO_VERSION=v0.18.2.0
WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) ARCH="x64"; SHA256SUM="83e6517dc9e5198228ee5af50f4bbccdb226fe69ff8dd54404dddb90a70b7322" ;; \
      aarch64* | arm64 | armv8*) ARCH="armv8"; SHA256SUM="fb20eaf9b04020abdf883eb339258814742a1452653c1f5d8705d16e90413f35" ;; \
      armv7*) ARCH="armv7"; SHA256SUM="1312afd0dde3262ff89554e278c0130c0ced6bdbeec8bf614fbb40bd03c6a0d2" ;; \
      *) echo "Unexpected architecture: $(uname -m)" && exit 1;; \
    esac \
    \
    && wget https://downloads.getmonero.org/cli/monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2 \
    && echo "${SHA256SUM}  monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xjvf monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2 --strip-components 1 \
    && rm -f monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2

##################
# --- runner --- #
##################
FROM docker.io/debian:11-slim AS runner

ENV PATH=/opt/monero:${PATH}

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tini ca-certificates && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt && \
    useradd -ms /bin/bash monero && \
    mkdir /opt/bitmonero && \
    ln -s /opt/bitmonero /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero && \
    chown -R monero:monero /opt/bitmonero

COPY --from=builder /opt/monero/* /opt/monero/

USER monero
WORKDIR /home/monero
VOLUME /opt/bitmonero
EXPOSE 18080 18081

ENTRYPOINT ["tini", "--" ,"/opt/monero/monerod"]
