# Chain info
Repo for chain information that are compatible with the Blockcore tooling (such as Explorer and Indexer).

If you are responsible for an Blockcore compatible blockchain, please provide a pull request to this repo with your details. Please include external links to logos, etc.

The chain files should use the exact same symbol as registered in the "official" SLIP-0044 list: https://github.com/satoshilabs/slips/blob/master/slip-0044.md

If your project/chain is not listed in the list yet, please go ahead and provide a PR to that and reserve your HD path and symbol.

The Blockcore devs reserves the rights to remove a chain from this repo at any time. Projects (chains) that are not responding and is not acting responsible, will likely be removed from this repo.


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
