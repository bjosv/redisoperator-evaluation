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

# RBAC for tiller
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller-cluster-rule \
        --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

helm2 init --upgrade --service-account tiller
sleep 40
kubectl get pods --all-namespaces
# helm2 repo add appscode https://charts.appscode.com/stable/
# helm2 repo update
# helm2 search appscode/kubedb

log "Installing operator.."
helm2 install --name kubedb-operator appscode/kubedb --set logLevel=${KUBEDB_LOGLEVEL} --version ${KUBEDB_VERSION} --namespace kube-system
sleep 60
kubectl --namespace=kube-system get deployments -l "release=kubedb-operator, app=kubedb"

log "Installing catalog.."
helm2 install --name kubedb-catalog appscode/kubedb-catalog --version ${KUBEDB_VERSION} --namespace kube-system
sleep 2

kubectl get pods --all-namespaces
log "Done"
