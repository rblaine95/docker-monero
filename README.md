# Docker Monero
My personal unprivileged Monero Docker image.  

[![Github tag (latest by date)](https://img.shields.io/github/v/tag/rblaine95/docker_monero "Github tag (latest by date)")](https://github.com/rblaine95/docker_monero/tags)  
[![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/rblaine95/docker_monero/Docker/master "Github Workflow Status (master)")](https://github.com/rblaine95/docker_monero/actions?query=workflow%3ADocker)  
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/rblaine/monero "Docker Image Size (latest by date)")](https://hub.docker.com/r/rblaine/monero)

Usage:
```sh
docker run \
  -dit \
  --restart=always \
  --net=host \
  --name=monerod \
  -v /path/to/bitmonero:/home/monero/.bitmonero \
  ghcr.io/rblaine95/monero ${EXTRA_MONEROD_ARGS}
```

### Where can I download the image?
I'm using Github Actions to build and publish this image to:
* [rblaine/monero](https://hub.docker.com/r/rblaine/monero)
* [quay.io/rblaine95/monero](https://quay.io/repository/rblaine95/monero)
* [ghcr.io/rblaine95/monero](https://ghcr.io/rblaine95/monero)

### Future stuff
I don't know, maybe I'll write a helm chart for this for Kubernetes?  
That might be fun.

### I want to buy you a coffee
This is just a hobby project for me, if you really want to buy me a coffee, thank you :)  

Monero: `8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U`  
![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U&amp;size=150x150 "8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U")

### I don't have Monero
You should definitly get some.  
* [monero-project/monero](https://github.com/monero-project/monero)
* [GetMonero.org](https://www.getmonero.org/)
* [/r/monero](https://www.reddit.com/r/monero)  
* [ChangeNow.io](https://changenow.io/)
* [MorphToken.com](https://www.morphtoken.com/)
* [Bisq.network](https://bisq.network/)
