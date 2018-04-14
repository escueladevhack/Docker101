#!/usr/bin/env bash

export PS4="\[\e[33m\]Running:\[\e[m\] "

set -eux

export DIGITALOCEAN_ACCESS_TOKEN="XXXXXXXXXXXXXXXX"
export DIGITALOCEAN_SSH_KEY_FINGERPRINT="XXXXXXXXXXXXXXX"
export DIGITALOCEAN_IMAGE="centos-7-x64" 
export DIGITALOCEAN_REGION="sfo2"
export DIGITALOCEAN_SIZE="s-1vcpu-2gb"


docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN    \
    --digitalocean-ssh-key-fingerprint $DIGITALOCEAN_SSH_KEY_FINGERPRINT \
    --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-region $DIGITALOCEAN_REGION \
    --digitalocean-size $DIGITALOCEAN_SIZE manager1

docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN    \
    --digitalocean-ssh-key-fingerprint $DIGITALOCEAN_SSH_KEY_FINGERPRINT \
    --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-region $DIGITALOCEAN_REGION \
    --digitalocean-size $DIGITALOCEAN_SIZE worker1

docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN    \
    --digitalocean-ssh-key-fingerprint $DIGITALOCEAN_SSH_KEY_FINGERPRINT \
    --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-region $DIGITALOCEAN_REGION \
    --digitalocean-size $DIGITALOCEAN_SIZE worker2

docker-machine create --driver digitalocean --digitalocean-access-token $DIGITALOCEAN_ACCESS_TOKEN    \
    --digitalocean-ssh-key-fingerprint $DIGITALOCEAN_SSH_KEY_FINGERPRINT \
    --digitalocean-image $DIGITALOCEAN_IMAGE --digitalocean-region $DIGITALOCEAN_REGION \
    --digitalocean-size $DIGITALOCEAN_SIZE worker3

# Let the Docker client talk to `manager1`
eval $(docker-machine env manager1)

# Get manager's IP
MANAGER_IP=$(docker-machine ip manager1)

# Initialize the Swarm with `manager1`'s IP as the advertised address
docker swarm init --advertise-addr "${MANAGER_IP}"

# Collect the join token for workers
WORKER_JOIN_TOKEN="$(docker swarm join-token -q worker)"

# Let the Docker client talk to `worker1`
eval $(docker-machine env worker1)

# Let `worker1` join the swarm
docker swarm join \
    --token "${WORKER_JOIN_TOKEN}" \
    --advertise-addr "$(docker-machine ip worker1)" \
    "${MANAGER_IP}":2377

# Let the Docker client talk to `worker2`
eval $(docker-machine env worker2)

# Let `worker2` join the swarm
docker swarm join \
    --token "${WORKER_JOIN_TOKEN}" \
    --advertise-addr "$(docker-machine ip worker2)" \
    "${MANAGER_IP}":2377

# Let the Docker client talk to `worker3`
eval $(docker-machine env worker3)

# Let `worker3` join the swarm
docker swarm join \
    --token "${WORKER_JOIN_TOKEN}" \
    --advertise-addr "$(docker-machine ip worker3)" \
    "${MANAGER_IP}":2377