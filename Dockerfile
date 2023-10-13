###################
# --- builder --- #
###################
FROM docker.io/debian:12-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      wget ca-certificates bzip2

ARG MONERO_VERSION=v0.18.3.1
WORKDIR /opt/monero
RUN case "$(uname -m)" in \
      x86_64) ARCH="x64"; SHA256SUM="23af572fdfe3459b9ab97e2e9aa7e3c11021c955d6064b801a27d7e8c21ae09d" ;; \
      aarch64* | arm64 | armv8*) ARCH="armv8"; SHA256SUM="445032e88dc07e51ac5fff7034752be530d1c4117d8d605100017bcd87c7b21f" ;; \
      armv7*) ARCH="armv7"; SHA256SUM="2ea2c8898cbab88f49423f4f6c15f2a94046cb4bbe827493dd061edc0fd5f1ca" ;; \
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
FROM docker.io/debian:12-slim AS runner

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
