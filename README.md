# Docker Monero

My personal unprivileged Monero Docker image.

[![Github tag (latest by date)][github-tag-badge]][github-tag-link]
[![GitHub Workflow Status (branch)][github-actions-badge]][github-actions-link]
[![Docker Image Size (latest by date)][docker-image-size-badge]][docker-image-link]

## IP Ban List
The Monero Research Lab (MRL) has identified a network of suspected spy nodes that may reduce transaction privacy on the Monero network.

While this Docker image doesn't package the ban list directly, we provide instructions for implementing it with your node.

### Background

These spy nodes are believed to be operated by adversaries attempting to deanonymize Monero transactions by:

* Proxying a few nodes through many IP addresses
* Creating high subnet saturation in specific IP ranges
* Potentially weakening Dandelion++ transaction privacy

For more detailed information, please see monero-project/meta#1124.

### Implementing the Ban List

1. Download the ban list:
```bash
wget -O ./monero-data/ban_list.txt \
  https://raw.githubusercontent.com/Boog900/monero-ban-list/refs/heads/main/ban_list.txt
```

2. Add the ban list to your node configuration using any of these methods:

#### Docker Compose

```yaml
services:
  monerod:
    container_name: monerod
    image: ghcr.io/rblaine95/monero
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./monero-data:/opt/bitmonero
    command:
      - --ban-list=/opt/bitmonero/ban_list.txt
```

#### Docker CLI

```bash
docker run \
  -dit \
  --restart=always \
  --net=host \
  --name=monerod \
  -v /path/to/bitmonero:/opt/bitmonero \
  -v /path/to/ban_list.txt:/ban_list.txt \
  ghcr.io/rblaine95/monero \
    --ban-list=/ban_list.txt
```

### Important notes

* Using the ban list is optional but recommended by MRL
* The ban list is maintained at [Boog900/monero-ban-list](https://github.com/Boog900/monero-ban-list)
* You may want to periodically update your ban list to include newly identified spy nodes
* The effectiveness of the ban list depends on widespread adoption by node operators

## Usage:
```sh
docker run \
  -dit \
  --restart=always \
  --net=host \
  --name=monerod \
  -v /path/to/bitmonero:/opt/bitmonero \
  ghcr.io/rblaine95/monero ${EXTRA_MONEROD_ARGS}
```

Running with [Tor](https://github.com/rblaine95/docker-tor):

```sh
docker run -d --name tor \
  --restart=always \
  -p 9050:9050 \
  -v $(pwd)/tor-data:/var/lib/tor \
  ghcr.io/rblaine95/tor

docker run -d --name monerod \
  --restart=always \
  --net=host \
  -v $(pwd)/monero:/opt/bitmonero \
  ghcr.io/rblaine95/monero \
    --non-interactive \
    --no-igd \
    --confirm-external-bind \
    --rpc-restricted-bind-port=18089 \
    --rpc-restricted-bind-ip=0.0.0.0 \
    --enable-dns-blocklist \
    --pad-transactions \
    --proxy=127.0.0.1:9050 \
    --tx-proxy=tor,127.0.0.1:9050,16
```

## Where can I download this image?

I'm using Github Actions to build and publish this image to:

* [ghcr.io/rblaine95/monero](https://ghcr.io/rblaine95/monero)
* [docker.io/rblaine/monero](https://hub.docker.com/r/rblaine/monero)

## I want to buy you a coffee

This is just a hobby project for me, if you really want to buy me a coffee, thank you :)

Monero: `83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh`
![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh&amp;size=150x150 "83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh")

## I don't have Monero

You should definitly get some.

* [monero-project/monero](https://github.com/monero-project/monero)
* [GetMonero.org](https://www.getmonero.org/)
* [/r/monero](https://www.reddit.com/r/monero)
* [OrangeFren](https://orangefren.com/)
* [Trocador](https://trocador.app/en/)
* [Haveno Reto](https://haveno-reto.com/)
* [Monero.com by Cake Wallet](https://monero.com/)

[github-tag-badge]: https://img.shields.io/github/v/tag/rblaine95/docker_monero "Github tag (latest by date)"
[github-tag-link]: https://github.com/rblaine95/docker_monero/tags
[github-actions-badge]: https://img.shields.io/github/actions/workflow/status/rblaine95/docker_monero/docker.yml?branch=master "Github Workflow Status (master)"
[github-actions-link]: https://github.com/rblaine95/docker_monero/actions?query=workflow%3ADocker
[docker-image-size-badge]: https://img.shields.io/docker/image-size/rblaine/monero/latest "Docker Image Size"
[docker-image-link]: https://hub.docker.com/r/rblaine/monero
