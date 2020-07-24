#!/usr/bin/env bash

set -eou pipefail

#K8S_VERSION=v1.16.9
K8S_VERSION=v1.15.11

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function log {
    echo -e "$GREEN`date +%Y-%m-%d_%H:%M:%S`" ">>> $1" $NC
}

log "Starting cluster.."
kind create cluster --wait 2m --image kindest/node:${K8S_VERSION} --config ./kind_multinode.yaml
kubectl get pods --all-namespaces

log "Waiting to make sure cluster is up.."
sleep 30
kubectl get pods --all-namespaces

log "Install operator..."
helm install operator ~/go/src/github.com/amadeusitgroup/redis-operator/chart/redis-operator
sleep 10
kubectl get pods --all-namespaces

log "Install DB..."
helm install cluster ./redis-cluster

kubectl get pods --all-namespaces
log "Pods starting up..."
