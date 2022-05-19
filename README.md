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
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable"
sudo apt update
sudo apt install docker-ce
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
sudo docker-compose up -d
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

## Hosting Web Wallet

The wallet can run in multiple different modes, one of them is web (Progressive Web App, PWA). There are security and privacy risks by allowing users to run their wallet directly in the web browser.

The hosted web wallet will attempt to enforce users to run as installed PWA, instead of directly in browser. This can potentially increase security.

```sh
cd docker/BLOCKCORE/WALLET
sudo sh ./wallet.sh 0.0.28
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

```sh
sudo docker-compose up -d
sudo docker network connect city_default proxy
```

After you start, you must connect the proxy network with the newly created network, like below:

```sh
sudo docker network connect blockcore_default proxy
sudo docker network connect exos_default proxy
sudo docker network connect ruta_default proxy
sudo docker network connect city_default proxy
sudo docker network connect btc_default proxy
sudo docker network connect strat_default proxy
sudo docker network connect x42_default proxy
sudo docker network connect xds_default proxy
sudo docker network connect xlr_default proxy
sudo docker network connect implx_default proxy
sudo docker network connect xrc_default proxy
sudo docker network connect home_default proxy
sudo docker network connect serf_default proxy
sudo docker network connect crs_default proxy
sudo docker network connect tcrs_default proxy
sudo docker network connect rsc_default proxy
sudo docker network connect sbc_default proxy
sudo docker network connect tstrax_default proxy
sudo docker network connect strax_default proxy
sudo docker network connect coinvault_default proxy
sudo docker network connect cybits_default proxy
```

If you host the paperwallet, you'll also need:
```
sudo docker network connect paperwallet_default proxy
```

Also if you run mongo-express for debugging:

```sh
sudo docker network connect city_default mongo-express
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


## Limiting Resource Usage

MongoDB which is used for Blockcore Indexer, will often utilize a fair amount of memory if it can.

If you want to restrict this, especially if you run more than a single instance on the same machine, you can do the following:

1. Configuring Ubuntu to Use Docker’s Limiting Resources Feature

```
sudo docker info
```

At the end of this command output, you should see:

WARNING: Noswaplimitsupport

2. Enable SWAP limit support.

```
sudo nano /etc/default/grub
```

Then edit and add the following

```
GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"
```

Then run:

```
sudo update-grub
```

Now you must restart your computer.

After restart, run the same command to see if warning is gone:

```
sudo docker info
```

3. Limit a Container's Memory Access

Set the `deploy.resources.limits` options in the docker-compose (v2.x) file and specifically for all the services.

```
  mongo:
    container_name: xlr-mongo
    image: mongo:5.0.5
```

4. Verify

If you run stats you can check if the container has an actual memory limit:

```
sudo docker stats
```

Then you can verify that MongoDB starts up with the restritions by looking in the log:

```
sudo docker logs -f xlr-mongo
```

# Blockcore Wallet Service (BWS)

The Blockcore Wallet Service is based upon a fork of Bitcore.

```
git clone repo
```

```
// Navigate to:
CITY/BWS/
```

```
sudo docker-compose up -d
```


# Debugging

## MongoDB - Database corruption

You can run the following command to repair corrupted database for bws-mongo:

```sh
docker run -it -v /var/lib/docker/volumes/city-bws-db/_data:/data/db -v /var/lib/docker/volumes/city-bws-db/_data:/data/configdb mongo:3.6.18 mongod --repair
```

## Backups

```sh
sudo cp -a /var/lib/docker/volumes/city-bws-db /home/blockcore/backup/docker/city-bws-db
```

## Top processes

```sh
sudo ps aux --sort -rss | head -10
```


# Logging

If left to run with default logging enabled, the containers will eventually use all available disk space for logging.

Ensure you configure your daemon.json to keep log files in check:

https://docs.docker.com/config/containers/logging/json-file/


## System Wide Configuration
Configure ```/etc/docker/``` on Linux hosts or ```C:\ProgramData\docker\config\``` on Windows Servers.

```
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3" 
  }
}
```
For the new configuration to take effect:

* Stop all Containers
* Restart the docker daemon
* Recreate the containers 


## Container Specific Configuration

Modify the file ```docker\<CHAIN>\docker-compose.yml``` and include the ```logging``` section as per example:
```
 chain:
    container_name: btc-chain
    mem_limit: 6000m
    image: blockcore/node-multi:1.1.41
    logging:
        driver: "json-file"
        options:
            max-file: 5
            max-size: 10m
    .
    .
    .
```
Options:
* ``` max-size ``` - The maximum size of the log before it is rolled. A positive integer plus a modifier representing the unit of measure (k, m, or g)
* ``` max-file ``` - The maximum number of log files that can be present. If rolling the logs creates excess files, the oldest file is removed. Only effective when max-size is also set. A positive integer

## 10 largest files

```
# Available space:
df -h
```

```
du -a /var | sort -n -r | head -n 10
```

```
find . -type f -printf '%s %p\n'| sort -nr | head -10
```

# mssql tipbot database restarts

The mssql container can get into trouble with the lock file.

When that happens, the container keeps restarting and the log says:

```sh
sudo docker logs -t --tail 1000 city-tipbot-db
```

```
2022-01-03T04:24:58.094242967Z 
2022-01-03T04:25:58.518057048Z SQL Server 2019 will run as non-root by default.
2022-01-03T04:25:58.518070343Z This container is running as user mssql.
2022-01-03T04:25:58.518072594Z Your master database file is owned by mssql.
2022-01-03T04:25:58.518074227Z To learn more visit https://go.microsoft.com/fwlink/?linkid=2099216.
2022-01-03T04:25:58.739964034Z sqlservr: Unable to read instance id from /var/opt/mssql/.system/instance_id: No such file or directory (2)
2022-01-03T04:25:58.740007717Z /opt/mssql/bin/sqlservr: PAL initialization failed. Error: 101
2022-01-03T04:25:58.740012125Z
```

This can be fixed by renaming the lock file:

```
# Stop the container
sudo docker stop city-tipbot-db

# Inspect to find volume path:
sudo docker inspect city-tipbot-db

# Navigate to:
cd /var/lib/docker/volumes/city-tipbot-db/_data/.system

# Move the file
mv instance_id instance_id.bak

sudo docker start city-tipbot-db
```

