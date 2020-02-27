# Chain info
Repo for chain information that are compatible with the Blockcore tooling (such as Explorer and Indexer).

If you are responsible for an Blockcore compatible blockchain, please provide a pull request to this repo with your details. Please include external links to logos, etc.

The chain files should use the exact same symbol as registered in the "official" SLIP-0044 list: https://github.com/satoshilabs/slips/blob/master/slip-0044.md

If your project/chain is not listed in the list yet, please go ahead and provide a PR to that and reserve your HD path and symbol.

The Blockcore devs reserves the rights to remove a chain from this repo at any time. Projects (chains) that are not responding and is not acting responsible, will likely be removed from this repo.

## Deployment

To deploy and run the indexer and explorer, you need a computer with Docker.

### Ubuntu 19.10

```sh
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable"
$ sudo apt update
$ sudo apt install docker-ce
```

Next you also need docker-compose. Make sure you run the installation like explained in the official documentation and not apt-get, as that repository has an older version of docker-compose.

https://docs.docker.com/compose/install/

```sh
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

## Docker

You can spin up both indexer and explorer locally, but it require a few minor edits. You must modify the listening ports of the indexer, 
so it doesn't attempt to use port 80, which also the explorer does.

Additionally you would need to modify the startup parameters for the explorer to use your localhost (docker-hosted) instance of the indexer.

1. Make sure only port 9910 is mapped on the indexer, default it maps to both that and port 80.

2. Add override argument to the command arguments in the explorer: --Explorer:Indexer:ApiUrl=http://127.0.0.1:9910/api/

```yml
   command: ["--chain=CITY", "--Explorer:Indexer:ApiUrl=http://127.0.0.1:9910/api/"]
```

Here is how you can run both indexer and explorer at the same time:

```sh
docker-compose -f CITY-indexer.yml -f CITY-explorer.yml up
``` 

```sh
// Cleanup the majority of resources (doesn't delete volumes)
docker system prune -a
```


### Reverse Proxy (route DNS to containers)

If you want to run multiple sites on the same docker host, you must run some sort of reverse proxy software.

[https://github.com/jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)

```sh
$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro --name blockcore-proxy jwilder/nginx-proxy
```

The proxy must be connected to your networks like this:

```sh
$ docker network connect city-network blockcore-proxy
$ docker network connect city_default_ blockcore-proxy
```