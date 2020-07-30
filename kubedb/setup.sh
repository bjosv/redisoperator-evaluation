#!/usr/bin/env bash

set -eou pipefail

ROOT="$(git rev-parse --show-toplevel)"

K8S_VERSION=v1.16.9

# Use appscode's helm repo
HELM_REPO=appscode
KUBEDB_VERSION=v0.13.0-rc.0

KUBEDB_LOGLEVEL=5

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function log {
    echo -e "$GREEN`date +%Y-%m-%d_%H:%M:%S`" ">>> $1" $NC
}

log "Starting K8s/kind cluster.."
kind create cluster --wait 2m --image kindest/node:${K8S_VERSION} --config $ROOT/kubedb/kind_multinode.yaml
kubectl get pods --all-namespaces

log "Waiting to make sure cluster is up.."
sleep 30
kubectl get pods --all-namespaces

# Add labels
kubectl get nodes --show-labels
LABELS="topology.kubernetes.io/region=us-east-1 failure-domain.beta.kubernetes.io/region=us-east-1 failure-domain.beta.kubernetes.io/zone=us-east-1a beta.kubernetes.io/instance-type=m3.medium"
for LABEL in $LABELS
do
    kubectl label nodes kind-worker  "$LABEL"
    kubectl label nodes kind-worker2 "$LABEL"
    kubectl label nodes kind-worker3 "$LABEL"
done
kubectl get nodes --show-labels

log "Installing operator.."
helm install kubedb-operator ${HELM_REPO}/kubedb --set logLevel=${KUBEDB_LOGLEVEL} --version ${KUBEDB_VERSION} --namespace kube-system
#     --set apiserver.enableMutatingWebhook=false,apiserver.enableValidatingWebhook=false

sleep 60
kubectl --namespace=kube-system get deployments -l "release=kubedb-operator, app=kubedb"

log "Installing catalog.."
helm install kubedb-catalog ${HELM_REPO}/kubedb-catalog --version ${KUBEDB_VERSION} --namespace kube-system \
     --set catalog.elasticsearch=false
sleep 2

     # --set catalog.elasticsearch=false,catalog.etcd=false,catalog.memcached=false,catalog.mongo=false,catalog.mysql=false,catalog.perconaxtradb=false,catalog.pgbouncer=false,catalog.postgres=false,catalog.proxysql=false

kubectl get pods --all-namespaces

kubectl create configmap rd-custom-config --from-file=redis.conf=$ROOT/kubedb/cluster-config.conf
kubectl get configmap/rd-custom-config -o yaml

log "Done"
