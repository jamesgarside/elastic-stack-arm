#! /bin/bash
docker-compose -f create_certs.yml run --rm create_certs
chown -R 1000:1000 certs/