#! /bin/bash

# Generate Certs
cd gen_certs/
./gen-certs-swarm.sh
cd ../

# Ensure environment vars are set
source .env

# Deploy Elastic Stack to Docker Swarm with default docker-compose.yml
sudo docker stack deploy $STACK_NAME -c resources/docker-compose-swarm.default.yml

# Carry out health check on locally deployed node until up
# Will return 401 as no creds have been created yet
RESPONSE=0
until [ $RESPONSE == 401 ]
do 
    RESPONSE=$(curl -k -o /dev/null -s -w "%{http_code}\n" https://localhost:9200)
    echo "Waiting for cluster to form"
    sleep 10 
done

# Generate cluster passwords on local Elasticsearch node
# Passwords get written to file stack-passwords.txt.
echo "Generating Passwords"
sudo docker exec $(sudo docker ps -f name=${STACK_NAME}_es01 -q) /bin/bash -c "bin/elasticsearch-setup-passwords auto --batch --url https://es01:9200" > stack-passwords.txt

# Create custom docker-compose file from default
cp resources/docker-compose-swarm.default.yml  docker-compose.yml

# Set kibana_system password within docker-compose.yml
KIBANA_PASSWORD=$(cat stack-passwords.txt | grep -oP '(?<=kibana_system = )(.*)')
sed -i "s/PleaseChangeMe/$KIBANA_PASSWORD/g" ./docker-compose.yml

# Set saved objects encryption key within docker-compose.yml
KIBANA_ENCRYPTIONKEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 48 ; echo '')
sed -i "s/PleaseChangeThisEncryptionKey/$KIBANA_ENCRYPTIONKEY/g" ./docker-compose.yml

# Set Cluster name within docker-compose.yml
sed -i "s/es-docker-cluster/$STACK_NAME/g" ./docker-compose.yml

# Re-deploy stack using new docker-compose
echo "Updating & Re-deploying Kibana"
sudo docker stack deploy $STACK_NAME -c docker-compose.yml