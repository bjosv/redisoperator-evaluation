# KubeDB

## Prepare
GO111MODULE="on" go get sigs.k8s.io/kind@v0.8.1

## Start cluster (1 CP, 3 workers)
### K8s 1.16.9
kind create cluster --image kindest/node:v1.16.9 --config ./kind_multinode.yaml
### K8s 1.17.5
kind create cluster --image kindest/node:v1.17.5 --config ./kind_multinode.yaml

## Option 2: Install KubeDB via helm
(Using Helm v3.2.3)

### Prepare
helm repo add appscode https://charts.appscode.com/stable/
helm repo update
helm search repo appscode/kubedb

### Install operator and CRDs (Latest stable: v0.12)
helm install kubedb-operator appscode/kubedb --version v0.13.0-rc.0 --namespace kube-system
#### Check CRDs (16 crds) and operator:
kubectl get crds -l app=kubedb
kubectl get pods --all-namespaces -l app=kubedb

### Install catalog
helm install kubedb-catalog appscode/kubedb-catalog --version v0.13.0-rc.0 --namespace kube-system
#### Check CRDs (1 crd):
kubectl get crds -l app=catalog
kubectl get redisversion

## Option 2: (Not working?) Install KubeDB via script
curl -fsSL https://github.com/kubedb/installer/raw/v0.13.0-rc.0/deploy/kubedb.sh | bash
!!! TIMEOUT !!! but ok when checking status
### Check status
kubectl get crd -l app=kubedb
kubectl get pods --all-namespaces -l app=kubedb --watch


## Install CLI (93MB)
KubeDB provides a CLI to work with database objects.

wget -O kubedb https://github.com/kubedb/cli/releases/download/0.12.0/kubedb-linux-amd64 \
  && chmod +x kubedb && mv kubedb ~/bin/


## Install DB

```
kubedb create -f demo.yaml
or
kubedb create -f demo2.yaml
```

#### Creates
6 pods         :  "Controlled By: StatefulSet/redis-cluster-2-shard0"
                  Ports:         6379/TCP, 16379/TCP
2 services     : redis-cluster-2 - port: 6379
                 kubedb          - no port, no ip, Type: ClusterIP
3 statefulsets : 2 replicas each
                 service account, volume claim, rolling update
1 AppBinding
1 Redis



### Check DB
kubedb describe rd redis-cluster

kubectl get statefulset
NAME                   READY   AGE
redis-cluster-shard0   2/2     23m
redis-cluster-shard1   2/2     22m
redis-cluster-shard2   2/2     22m

kubectl get pvc
kubectl get pv

kubectl get service
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubedb          ClusterIP   None             <none>        <none>     24m
redis-cluster   ClusterIP   10.110.141.171   <none>        6379/TCP   24m


### Enter redis instance container
kubectl exec -it redis-cluster-shard0-0 -n demo -c redis -- sh

> cat /usr/local/etc/redis/redis.conf
cluster-enabled yes
cluster-config-file /data/nodes.conf
cluster-node-timeout 5000
cluster-migration-barrier 1
dir /data
appendonly yes
protected-mode no

> cat /data/nodes.conf
17fbba935562faf4aca291fd741aba929c3e1230 10.244.1.3:6379@16379 slave 848dd1e5672b9c86a00ece11c720b6c62e1a7803 0 1592217526000 1 connected
b75fadd2d8719b8125f3ef8b8ecb03e4dc9fbeb7 10.244.1.7:6379@16379 slave eb1ef0fae82286c18d73da296f977a11d69a4d9e 0 1592217526458 3 connected
848dd1e5672b9c86a00ece11c720b6c62e1a7803 10.244.2.3:6379@16379 myself,master - 0 1592217526000 1 connected 0-5460
eb1ef0fae82286c18d73da296f977a11d69a4d9e 10.244.3.4:6379@16379 master - 0 1592217526252 3 connected 10923-16383
8e401fbacc65b6fe5520d4d622849e0118bbe4ff 10.244.1.5:6379@16379 master - 0 1592217525248 2 connected 5461-10922
934a1a1e8a389c3a7452dc8112866e69ea0afe4f 10.244.2.5:6379@16379 slave 8e401fbacc65b6fe5520d4d622849e0118bbe4ff 0 1592217527255 2 connected
vars currentEpoch 3 lastVoteEpoch 0

### Start redis-cli
redis-cli -c -h $POD_IP
set hello world

### Switch to replica
redis-cli -c -h 10.244.1.3
get hello

### Crash master
redis-cli -c -h 10.244.2.3 debug segfault


# Update master from 3 to 4, edit:
kubedb edit -f demo.yaml --namespace=demo


# INFO
Containers:
https://hub.docker.com/u/kubedb

docker exec -it f02b81c4c76f /bin/sh
/conf/fix-ip.sh:  Update my IP in /data/nodes.conf with $POD_IP
