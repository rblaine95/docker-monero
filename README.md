# Docker Monero

My personal unprivileged Monero Docker image.

[![Github tag (latest by date)][github-tag-badge]][github-tag-link]

[![GitHub Workflow Status (branch)][github-actions-badge]][github-actions-link]

[![Docker Image Size (latest by date)][docker-image-size-badge]][docker-image-link]

Usage:
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
  ghcr.io/rblaine95/monero:0.18.3.4-2 \
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

### Where can I download this image?

I'm using Github Actions to build and publish this image to:

* [ghcr.io/rblaine95/monero](https://ghcr.io/rblaine95/monero)
* [docker.io/rblaine/monero](https://hub.docker.com/r/rblaine/monero)

### I want to buy you a coffee

This is just a hobby project for me, if you really want to buy me a coffee, thank you :)

Monero: `83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh`
![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh&amp;size=150x150 "83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh")

### I don't have Monero

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
