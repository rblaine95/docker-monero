###################
# --- builder --- #
###################
FROM docker.io/debian:12-slim AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y \
      wget ca-certificates bzip2 gnupg git

ARG MONERO_VERSION=v0.18.4.1
WORKDIR /opt/monero

RUN git clone --filter=blob:none --sparse https://github.com/monero-project/monero -b ${MONERO_VERSION} && \
    cd monero && \
    git sparse-checkout set utils/gpg_keys && \
    mkdir -p /root/.gnupg && \
    chmod 700 /root/.gnupg && \
    for key in utils/gpg_keys/*.asc; do \
        gpg --import "$key"; \
    done && \
    cd .. && \
    rm -rf monero

RUN wget -q -O hashes.txt https://www.getmonero.org/downloads/hashes.txt && \
    wget -q -O hashes.txt.sig https://www.getmonero.org/downloads/hashes.txt.sig && \
    gpg --verify hashes.txt.sig hashes.txt || true && \
    case "$(uname -m)" in \
      x86_64) ARCH="x64" ;; \
      aarch64* | arm64 | armv8*) ARCH="armv8" ;; \
      armv7*) ARCH="armv7" ;; \
      *) echo "Unexpected architecture: $(uname -m)" && exit 1;; \
    esac && \
    MONERO_HASH=$(grep "monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2" hashes.txt | cut -d' ' -f1) && \
    if [ -z "$MONERO_HASH" ]; then \
        echo "Hash not found for architecture ${ARCH} and version ${MONERO_VERSION}" && \
        exit 1; \
    fi && \
    wget https://downloads.getmonero.org/cli/monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2 && \
    echo "${MONERO_HASH}  monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2" | sha256sum -c && \
    tar -xjf monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2 --strip-components 1 && \
    rm -f monero-linux-${ARCH}-${MONERO_VERSION}.tar.bz2 hashes.txt hashes.txt.sig

##################
# --- runner --- #
##################
FROM docker.io/debian:12-slim AS runner

ENV PATH=/opt/monero:${PATH}

RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y tini ca-certificates curl && \
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

# P2P
EXPOSE 18080
# RPC
EXPOSE 18081
# RPC Restricted
EXPOSE 18089

HEALTHCHECK CMD curl --fail http://127.0.0.1:18081/get_height || exit 1

ENTRYPOINT ["tini", "--" ,"/opt/monero/monerod"]
