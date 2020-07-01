#!/usr/bin/env bash

set -eou pipefail

KIND_VERSION=v1.16.9
KUBEDB_VERSION=v0.13.0-rc.0
KUBEDB_LOGLEVEL=5

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function log {
    echo -e "$GREEN`date +%Y-%m-%d_%H:%M:%S`" ">>> $1" $NC
}

log "Starting cluster.."
kind create cluster --wait 2m --image kindest/node:${KIND_VERSION} --config ./kind_multinode.yaml
kubectl get pods --all-namespaces

log "Installing operator.."
helm install kubedb-operator appscode/kubedb --set logLevel=${KUBEDB_LOGLEVEL} --version ${KUBEDB_VERSION} --namespace kube-system
sleep 30
kubectl --namespace=kube-system get deployments -l "release=kubedb-operator, app=kubedb"

log "Installing catalog.."
helm install kubedb-catalog appscode/kubedb-catalog --version ${KUBEDB_VERSION} --namespace kube-system
sleep 2

kubectl get pods --all-namespaces
log "Done"
