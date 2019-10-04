#!/bin/bash

# install gdrive and download file
wget https://docs.google.com/uc?id=0B3X9GlR6EmbnWksyTEtCM0VfaFE&export=download
sleep 5
mv uc\?id\=0B3X9GlR6EmbnWksyTEtCM0VfaFE gdrive
chmod +x gdrive
sudo install gdrive /usr/local/bin/gdrive
gdrive list 
gdrive download $(gdrive list | grep 'docker.tar.gz' |head -n1 | awk '{print $1;}')
gdrive download $(gdrive list | grep 'oracle-database-xe-18c-1.0-1.x86_64.rpm' |head -n1 | awk '{print $1;}')

# extract volume file
tar -xvzf docker.tar.gz

# build  docker image
docker network create oracle_network
git clone https://github.com/scz10/docker-oracle-xe.git
cp oracle-database-xe-18c-1.0-1.x86_64.rpm ~/docker-oracle-xe/files/
cd docker-oracle-xe
docker build -t oracle-xe:18c .

# run container with existing volume data
docker run -d \
  -p 32118:1521 \
  -p 35518:5500 \
  --name=oracle-xe \
  --volume ~/docker/oracle-xe:/opt/oracle/oradata \
  --network=oracle_network \
  oracle-xe:18c
