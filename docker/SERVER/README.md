# Host a Blockcore Infrastructure Server

To host a Blockcore infrastructure server that runs a single chain, or multiple, you can use these instructions.

1. Perform the setup described in the main README.md
2. Run shell:

```sh
sudo docker-compose up -d
``` 

3. After the two containers for nginx and letsencrypt has started up, you need to connect the virtual networks.

```sh
sudo docker network connect city-network proxy
sudo docker network connect city_default proxy
``` 

You might need to find the correct names if these doesn't work, or if you have other networks you must change prefix.

More information: https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion



