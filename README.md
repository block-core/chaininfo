# Blockcore Chain Info
Repo for chain information that are compatible with the Blockcore tooling (such as Explorer and Indexer).

If you are responsible for an Blockcore compatible blockchain, please provide a pull request to this repo with your details. Please include external links to logos, etc.

The chain files should use the exact same symbol as registered in the "official" SLIP-0044 list: https://github.com/satoshilabs/slips/blob/master/slip-0044.md

If your project/chain is not listed in the list yet, please go ahead and provide a PR to that and reserve your HD path and symbol.

The Blockcore devs reserves the rights to remove a chain from this repo at any time. Projects (chains) that are not responding and is not acting responsible, will likely be removed from this repo.

# Add your own chain

Feel free to go ahead and duplicate one of the existing configurations for a chain, and create a pull request for us to approve. It is fairl self-describing how to do it if you look at existing files and setup.

# Host a Blockcore Infrastructure Server

## Server Deployment

To deploy and run the indexer and explorer, you need a computer with Docker. As long as Docker (Linux/Windows) is supported, you should be able to run your own Blockcore Infrastructure Server (BIS).

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

Then apply executable permissoins:
```sh
sudo chmod +x /usr/local/bin/docker-compose
```

### Reverse Proxy (route DNS to containers)

Next step is to navigate to the docker/SERVER folder.

```sh
sudo docker-compose up -d
``` 

This will start both an Let's Encrypt container and Proxy container. These will redirect HTTP traffic to the correct chain containers.

You might need to find the correct names if these doesn't work, or if you have other networks you must change prefix.

More information: https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion

When this is done, you must ensure local firewall has open traffic for TCP 80 and TCP 443. If you run server behind a gateway/router, you must forward public traffic on port 80 and 443 and route that to the IP address of your server.

### Domain Names

What domain names your explorer and indexer will respond to, is controlled by the VIRTUAL_HOST and LETSENCRYPT_HOST environment variables. You must edit these before you run up a chain.

```yml
    environment:
      VIRTUAL_HOST: city.indexer.blockcore.net
      LETSENCRYPT_HOST: city.indexer.blockcore.net
      LETSENCRYPT_EMAIL: admin@blockcore.net
```

Then modify your DNS entry with your DNS provider to target your network public IP.

### Running a chain

All supported chains should be located within the "docker" folder. Navigate to either of the sub-folders, and run a docker-compose with multiple file targets to ensure you run both indexer and explorer.

Here is how you can run both indexer and explorer at the same time:

```sh
sudo docker-compose -f indexer.yml -f explorer.yml up -d
``` 

Due to the way custom network is setup for the node and indexer, you need to connect the proxy with the custom networks. You do this, after you have run/started the individual proxies:

```sh
$ sudo docker network connect city-network blockcore-proxy
$ sudo docker network connect city_default_ blockcore-proxy
```

### Local Image Dependency (Optional)

Normally your locally running Explorer, will attempt to request your Indexer, using public traffic. It will read the JSON configuration file hosted on chains.blockcore.net and forward traffic through your router. You can manually override this with the following instructions:

You can spin up both indexer and explorer locally, but it require a few minor edits. You must modify the listening ports of the indexer, 
so it doesn't attempt to use port 80, which also the explorer does.

Additionally you would need to modify the startup parameters for the explorer to use your localhost (docker-hosted) instance of the indexer.

1. Make sure only port 9910 is mapped on the indexer, default it maps to both that and port 80.

2. Add override argument to the command arguments in the explorer: --Explorer:Indexer:ApiUrl=http://127.0.0.1:9910/api/

```yml
   command: ["--chain=CITY", "--Explorer:Indexer:ApiUrl=http://127.0.0.1:9910/api/"]
```

### Clean Your Docker Instance

```sh
// Cleanup the majority of resources (doesn't delete volumes)
sudo docker system prune -a
```

## Debugging network issues

There are many things that can be problematic with a setup with reverse proxy, certificates, etc.

Here are some useful debugging commands:

Output the configuration of the nginx reverse proxy:
```
sudo docker exec proxy cat /etc/nginx/conf.d/default.conf
```

## Examples

Navigate into the chaininfo/docker/CHAIN folders and run these commands.

### Spin up docker containers

sudo docker-compose -f indexer.yml -f explorer.yml up -d

After this, you must connect the networks between the chain, and the proxy/lets-encrypt containers:

### CITY

```
sudo docker network connect city-network proxy
sudo docker network connect city_default proxy
```

### STRAT

```
sudo docker network connect strat-network proxy
sudo docker network connect strat_default proxy
```

### X42

```
sudo docker network connect x42-network proxy
sudo docker network connect x42_default proxy
```

### XDS

```
sudo docker network connect xds-network proxy
sudo docker network connect xds_default proxy
```

### XLR

```
sudo docker network connect xlr-network proxy
sudo docker network connect xlr_default proxy
```

### CHAINS

To run multichain explorer, navigate to the BLOCKCORE folder and run:

```
sudo docker-compose -f explorer.yml up -d
sudo docker network connect blockcore_default proxy
```

## Additional docker information.

Use the down command stop and start up again. This should remove container data, except persistent volumes.
```
sudo docker-compose down
```

Look into the running container
```
sudo docker exec -it xlr-chain /bin/bash
```

Data folders are located in:
```
/root/.blockcore/xlr/
```
