[![Docker Repository on Quay](https://quay.io/repository/rblaine95/monero/status "Docker Repository on Quay")](https://quay.io/repository/rblaine95/monero)

### Docker Monero
My personal Monero Docker image.  

Usage:
```sh
docker run \
  -d \
  --restart=always \
  -p 18080:18080 \
  -p 18081:18081 \
  -v /path/to/bitmonero:/home/monero/.bitmonero \
  quay.io/rblaine95/monero ${EXTRA_MONEROD_ARGS}
```

### Future stuff
I don't know, maybe I'll write a helm chart for this for Kubernetes?  
That might be fun.

### I want to buy you a coffee
This is just a hobby project for me, if you really want to buy me a coffee, thank you :)  

Monero: `84S1P3qYJgeVtsPUS5gFXLVoiD4Pn55T31FBihryEgy4FYseZvuQg5H9ziwyMAXY2Bf5ewg9GH1fiSkjprrC37NP4inWEov`

### I don't have Monero
You should definitly get some.  
* [GetMonero.org](https://www.getmonero.org/)
* [/r/monero](https://www.reddit.com/r/monero)  
* [ChangeNow.io](https://changenow.io/)
* [MorphToken.com](https://www.morphtoken.com/)
* [Bisq.network](https://bisq.network/)
