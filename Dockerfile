###################
# --- builder --- #
###################
FROM docker.io/debian:11-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      wget ca-certificates bzip2

ARG MONERO_VERSION=v0.18.2.2
WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) ARCH="x64"; SHA256SUM="186800de18f67cca8475ce392168aabeb5709a8f8058b0f7919d7c693786d56b" ;; \
      aarch64* | arm64 | armv8*) ARCH="armv8"; SHA256SUM="f3867f2865cb98ab1d18f30adfd9168f397bd07bf7c36550dfe3a2a11fc789ba" ;; \
      armv7*) ARCH="armv7"; SHA256SUM="11b70a9965e3749970531baaa6c9d636b631d8b0a0256ee23a8e519f13b4b300" ;; \
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
