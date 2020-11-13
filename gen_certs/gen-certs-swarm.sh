#! /bin/bash
docker-compose -f create_certs.yml run --rm create_certs
chown -R 1000:1000 certs/

# Finds certs & Keys and stores them as secrets within Docker
for f in $(find -name '*.crt' -or -name '*.key');
do 
    basename $f
    sudo docker secret create $(basename $f) $f;
done

rm -rf certs/