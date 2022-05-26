# Blockcore DNS

Domain Name System Server that utilizes Decentralized Identifiers (DIDs) for updates.  

## Getting started

This is a guide on how to setup blockcore dns.   
To read more head on to the repo https://github.com/block-core/blockcore-dns

This instructions assuming docker and and are used with the blockcore docker dompose files (but it can also be run on a window)

## Deploy a dns server

We recommend using a public node with a static ip address.  
For example Digital Ocean have $5 vms which will be greate for a blockcore-dns server

#### Download the files 

- .env.sample
- docker-compose.yml

Modify the file `.env.sample` (if you rename it then also rename it in the `docker-compose.yml`)  
to add identities of agents that are allowed to register dns data

#### Open port 53

On linux by default port 53 is used by the system for dns resolution to make sure port 53 is available see this guide  
https://github.com/block-core/blockcore-dns#open-port-53-linux

#### Deploy Reverse Proxy

Follow the instructions here
https://github.com/block-core/chaininfo#reverse-proxy-route-dns-to-containers

Start the nginx revers proxy container

#### Get a sub domain

The DNS server will be used by the blockcore software and for securty it's best to have it behind a secure connection  
Either purchas a dommain or reuse one you already have

Our convention is to put DNS servers behind a subdomin under the letter `ns` e.g "ns.blockcore.net"
Point your sub domain to the ip address of your publiuc server

Update the `docker-compose.yml` with the your subdomain in the following entries

```yml
    environment:
      VIRTUAL_HOST: ns.blockcore.net
      LETSENCRYPT_HOST: ns.blockcore.net
      LETSENCRYPT_EMAIL: admin@blockcore.net
```

#### Start the dns server
Next step is to start the DNS server

```sh
sudo docker-compose up -d
``` 

To observe the logs 
```sh
sudo docker-compose logs -f --tail=100
``` 

Verify the server is running navigate to your subdomain  
For exmaple https://ns.blockcore.net/docs/index.html

#### To add more identities 

Add (or remove) any new identity to the `.env.sample` file (or change any config value)  
Then run again the command

```sh
sudo docker-compose up -d
``` 

This will recreate the containers with the new identities

## Deploy a dns agent

Before deployning an agent we need to generate a DID

### Generating a DID (Decentralized Identifier)

```sh
docker run --rm blockcore/dns:0.0.3 --did
```

This will result in a secret and a DID, for exmaple:

```
Secret key add to config 6e371a4ff7abc88d961014e02c3e6f35cd645f6ea8ba78aa8129e54cb0e5e78f
Public identity did:is:02e55470d8898dbb7869575552c3b5f3a4a6bb8cbc14b75831249a50a33eeb2625
```

Give the public identity DID to any dns server you wish to register and get dns services with

#### Download the files 

Navigate to `docker/SERVER-DNS/DNS-AGENT/` and download

- .env.sample
- docker-compose.yml

Modify the file `.env.sample` (if you rename it then also rename it in the `docker-compose.yml`)   

Set the Secret generated earlier as following `DnsAgent__Secret=6e371a4ff7abc88d961014e02c3e6f35cd645f6ea8ba78aa8129e54cb0e5e78f`

Next for each service you are running (i.e indexer, vault etc..) that needs to register with a DNS add an to the group of entries as bellow, for each group increment the `__0__` (for the next group use `__1__` etc...)

Set your service domain and the DNS server host accordingly (don't forget to set the port correctly if running more then one service)

```
DnsAgent__Hosts__0__DnsHost=http://ns.blockcore.net:7010
DnsAgent__Hosts__0__Domain=btc.indexer.blockcore.net
DnsAgent__Hosts__0__Port=9910
DnsAgent__Hosts__0__Symbol=BTC
DnsAgent__Hosts__0__Service=Indexer
```

Now run the dns agent
```sh
sudo docker-compose up -d
``` 

#### Using the DNS server to resolve domains

A Blockcore DNS server will be able to resolve domain names to the ip address where your service are running (i.e indexer, vault), if the ip address changes frequently (dynamicly allocated) the DNS agent will notify the dns servers of such changes to your ip address.  

To use a Blockcore DNS server to resolve ip address  
Point the subdomain (i.e btc.indexer.blockcore.net) to resolve as an NS record and provide the domain of a Blockore DNS server
