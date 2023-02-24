###################
# --- builder --- #
###################
FROM docker.io/debian:11-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      wget ca-certificates bzip2

ARG MONERO_VERSION=v0.18.1.2
WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) ARCH="x64"; SHA256SUM="7d51e7072351f65d0c7909e745827cfd3b00abe5e7c4cc4c104a3c9b526da07e" ;; \
      aarch64* | arm64 | armv8*) ARCH="armv8"; SHA256SUM="e1467fe289c98349be2b1c4c080e30a224eb3217c814fab0204241b2b19b9c6b" ;; \
      armv7*) ARCH="armv7"; SHA256SUM="94ece435ed60f85904114643482c2b6716f74bf97040a7af237450574a9cf06d" ;; \
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
