# Blockcore DNS

Domain Name System Server that utilizes Decentralized Identifiers (DIDs) for updates.

## Getting started

This is a guide on how to setup Blockcore DNS.   
Source: https://github.com/block-core/blockcore-dns

This instructions assume docker is used with the blockcore docker compose files (but it can also be run on a window). You also need to make sure that [docker-compose](https://github.com/block-core/chaininfo#host-a-blockcore-infrastructure-server) is installed.

## Deploy a DNS server

We recommend using a public node with a static ip address.  
For example Digital Ocean have $5 VPS which will be great for a blockcore-dns server

## Setup instructions

Follow these instructions to fully setup your own Blockcore DNS Server:

### Open firewall ports on your server

TCP port 80 and 443. This is required for TLS (certificate) requests.   
TCP and UDP port 53. This is used for DNS lookup requests.

See instructions: https://github.com/block-core/blockcore-dns#open-port-53-linux

### Shell commands

Connect to your server using SSH, and run the following commands:

```sh
git clone https://github.com/block-core/chaininfo.git
cd chaininfo/docker/SERVER/
# Runs the nginx reverse proxy and letsencrypt agent for TLS certificates
sudo docker-compose up -d
cd ..
cd SERVER-DNS
# Open file and edit the settings.
nano .env.sample
# Open file and edit the settings, see info below
nano docker-compose.yml
# Start the Blockcore DNS Server, see info below
sudo docker-compose up -d
```

To verify the DNS server is running navigate to your subdomain  
For example https://ns.blockcore.net/docs/index.html

### docker-compose.yml

Modify the domain entry for `VIRTUAL_HOST` and `LETSENCRYPT_HOST` and `LETSENCRYPT_EMAIL`.

### .env.sample

Modify the file `.env.sample` to add identities of agents that are allowed to register dns data

### Port 53 already in use

It is likely that port 53 is already in use with errors such as `udp4 0.0.0.0:53: bind: address already in use
`.   
Run these commands to mitigate the problem:

```sh
nano /etc/systemd/resolved.conf

# Set parameters like this:
DNS=1.1.1.1
DNSStubListener=no

# Create a link
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Restart the server
reboot
```

## Get a sub domain

The DNS server will be used by the blockcore software and for securty it's best to have it behind a secure connection  
Either purchas a dommain or reuse one you already have

Our convention is to put DNS servers behind a subdomin under the letter `ns` e.g "ns.blockcore.net"  
Point your sub domain to the ip address of your public server

Update the `docker-compose.yml` with your subdomain in the following entries:

```yml
    environment:
      VIRTUAL_HOST: ns.blockcore.net
      LETSENCRYPT_HOST: ns.blockcore.net
      LETSENCRYPT_EMAIL: admin@blockcore.net
```

### To add more identities 

Add (or remove) any new identity to the `.env.sample` file (or change any config value)  
Then run again the command:

```sh
sudo docker-compose up -d
``` 

This will recreate the containers with the new identities.

## Deploy a DNS Agent

Before deploying an agent we need to generate a DID.

Find latest version of the docker image: https://hub.docker.com/repository/docker/blockcore/dns

### Generating a DID (Decentralized Identifier)

```sh
docker run --rm blockcore/dns:latest --did
```

This will result in a secret and a DID, for exmaple:

```
Secret key add to config 6e371a4ff7abc88d961014e02c3e6f35cd645f6ea8ba78aa8129e54cb0e5e78f
Public identity did:is:02e55470d8898dbb7869575552c3b5f3a4a6bb8cbc14b75831249a50a33eeb2625
```

Give the public identity DID to any dns server you wish to register and get dns services from  

### Download the files 

Navigate to `docker/SERVER-DNS/DNS-AGENT/` and download

- .env.sample
- docker-compose.yml

Modify the file `.env.sample` (if you rename it then also rename it in the `docker-compose.yml`)   

Set the Secret generated earlier as following `DnsAgent__Secret=6e371a4ff7abc88d961014e02c3e6f35cd645f6ea8ba78aa8129e54cb0e5e78f`

Next for each service you are running (i.e indexer, vault etc..) that needs to register with a DNS add an entry to the group of entries as bellow, for each group increment the `__0__` (for the next group use `__1__` etc...)

Set your service domain and the DNS server host accordingly (don't forget to set the port correctly if running more then one service)

```
DnsAgent__Hosts__0__DnsHost=https://ns.blockcore.net
DnsAgent__Hosts__0__Domain=btc.indexer.blockcore.net
DnsAgent__Hosts__0__Port=9910
DnsAgent__Hosts__0__Symbol=BTC
DnsAgent__Hosts__0__Service=Indexer

DnsAgent__Hosts__1__DnsHost=https://ns.blockcore.net
DnsAgent__Hosts__1__Domain=city.indexer.blockcore.net
DnsAgent__Hosts__1__Port=9920
DnsAgent__Hosts__1__Symbol=CITY
DnsAgent__Hosts__1__Service=Indexer
```

Now run the dns agent
```sh
sudo docker-compose up -d
``` 

#### Using the DNS server to resolve domains

A Blockcore DNS server will be able to resolve domain names to the ip address where your services are running (i.e indexers, vault), if the ip address changes frequently (dynamicly allocated) the DNS agent will notify the dns servers of such changes to your ip address.  

To use a Blockcore DNS server to resolve ip address  
At the domain registrar and point the subdomain (i.e btc.indexer.blockcore.net) to resolve as an NS record and provide the domain of a Blockore DNS server  

For example:  
btc.indexer.blockcore.net -> NS -> ns.blockcore.net

