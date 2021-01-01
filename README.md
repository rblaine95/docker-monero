# Docker Monero
My personal Monero Docker image.  

[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rblaine95/docker_monero "GitHub tag (latest by date)")](https://github.com/rblaine95/docker_monero/tags)  
[![Docker Repository on Quay](https://quay.io/repository/rblaine95/monero/status "Docker Repository on Quay")](https://quay.io/repository/rblaine95/monero)  
[![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/rblaine/monero "Docker Image Size (latest by date)")](https://hub.docker.com/r/rblaine/monero)

Usage:
```sh
docker run \
  -d \
  --restart=always \
  --net=host \
  -v /path/to/bitmonero:/home/monero/.bitmonero \
  quay.io/rblaine95/monero ${EXTRA_MONEROD_ARGS}
```

### Future stuff
I don't know, maybe I'll write a helm chart for this for Kubernetes?  
That might be fun.

### I want to buy you a coffee
This is just a hobby project for me, if you really want to buy me a coffee, thank you :)  

Monero: `8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U`  
![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U&amp;size=150x150 "8AoCMLDJ4J4fkeEokYT1QQbVd7vemd7nHVH1uurxng3cXx1wdKKdp14Fk1PDws4vkagHRF2BkdQo9DfzxxpEr4pUCaGWb5U")

### I don't have Monero
You should definitly get some.  
* [GetMonero.org](https://www.getmonero.org/)
* [/r/monero](https://www.reddit.com/r/monero)  
* [ChangeNow.io](https://changenow.io/)
* [MorphToken.com](https://www.morphtoken.com/)
* [Bisq.network](https://bisq.network/)
