# Generate certs for the Elastic Stack
This method is based off the Offical Elastic deployment guide with some modifications.
- Uses local directory rather than Docker volume to store certs
- Uses Docker secrets to store crypt if using Docker Swarm

## How To
1. Update `instances.yml`
2. Run gen script based on your Docker deployment.

### instances.yml
Update the `instances.yml` file to list all the Elastic Stack components you wish to deploy.

### Docker Swarm
If you are using Docker Swam execute the `gen-certs-swarm.sh` script. This will generate crypt based off the `instances.yml` file then store all files as docker secrets. Secrets allow containers on all Swarm nodes to access to the relevant crypt files as well prevents them being stored in plain text

### Non Docker Swarm
Execute the `gen-certs.sh` script. This will generate crypt based off the `instances.yml` file then store all files in the directory `certs/`. 
This directory will then need placing in whichever location is specified within the `$CERTS_DIR` environment var.


## Credit
This method is based off the Offical Elastic deployment guide. - https://www.elastic.co/guide/en/elastic-stack-get-started/current/get-started-docker.html