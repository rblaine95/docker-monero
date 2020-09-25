FROM debian:buster

ARG MONERO_VERSION=0.17.0.0
ARG MONERO_SHA256=29a1a3d2d4a6bcbaccba0a8016be43c36c88523c358c721d9886e1f0c5ae662d
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
    ln -s /opt/monero-x86_64-linux-gnu-v${MONERO_VERSION} /opt/monero

USER monero

WORKDIR /home/monero

VOLUME /home/monero/.bitmonero

EXPOSE 18080 18081

ENTRYPOINT ["/opt/monero/monerod"]
