FROM debian:buster

ARG MONERO_VERSION=0.16.0.1
ARG MONERO_SHA256=4615b9326b9f57565193f5bfe092c05f7609afdc37c76def81ee7d324cb07f35
ENV PATH=/opt/monero:${PATH}

WORKDIR /opt

RUN apt update && \
    apt -y upgrade && \
    apt -y install curl bzip2 && \
    apt clean && \
    apt -y autoremove && \
    useradd -ms /bin/bash monero && \
    mkdir -p /home/monero/.bitmonero && \
    chown -R monero:monero /home/monero/.bitmonero && \
    curl https://downloads.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2 -O && \
    echo "$MONERO_SHA256  monero-linux-x64-v$MONERO_VERSION.tar.bz2" | sha256sum -c - && \
    tar -xvf monero-linux-x64-v$MONERO_VERSION.tar.bz2 && \
    rm -f monero-linux-x64-v$MONERO_VERSION.tar.bz2 && \
    ln -s /opt/monero-x86_64-linux-gnu-v0.16.0.1 /opt/monero

USER monero

WORKDIR /home/monero

VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081

ENTRYPOINT ["/opt/monero/monerod"]
