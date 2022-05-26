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

### Generating a DID (Decentralized Identifier)

```sh
docker run --rm blockcore/dns:0.0.3 --did
```

This will result in a secret and a DID keep those for later

```
Secret key add to config 6e371a4ff7abc88d961014e02c3e6f35cd645f6ea8ba78aa8129e54cb0e5e78f
Public identity did:is:02e55470d8898dbb7869575552c3b5f3a4a6bb8cbc14b75831249a50a33eeb2625
```
