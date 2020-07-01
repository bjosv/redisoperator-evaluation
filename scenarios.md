# Setup

### KubeDB
```
cd kubedb

# Setup K8s and KubeDB operator + catalog
./setup.sh

# Create Redis config
kubectl create configmap rd-custom-config --from-file=redis.conf=./cluster-config.conf
kubectl get configmap/rd-custom-config -o yaml

# Install DB
kubectl apply -f demo_3master.yaml

# Fill with data (!! Update REDIS_HOST ENV)
make -C ~/git/redis-job run
kubectl get jobs

kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master
pod/rediscluster-cluster-28jcs

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli DBSIZE
kubectl exec redis-cluster-3master-shard1-0 -- redis-cli DBSIZE
kubectl exec redis-cluster-3master-shard2-0 -- redis-cli DBSIZE
```

### Redis-Cluster
```
cd redis-cluster

kind create cluster --image kindest/node:v1.15.11 --config ./kind_multinode.yaml

# Install operator
helm install operator ~/go/src/github.com/amadeusitgroup/redis-operator/chart/redis-operator

# Install DB
helm install cluster ./redis-cluster

# Fill with data (!! Update REDIS_HOST ENV)
make -C ~/git/redis-job run
kubectl get jobs
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master
kubectl get pods -l app=redis-cluster -o wide

kubectl exec rediscluster-cluster-b65x5 -- redis-cli DBSIZE
kubectl exec rediscluster-cluster-v6t2d -- redis-cli DBSIZE
kubectl exec rediscluster-cluster-q7s9h -- redis-cli DBSIZE
```

# Scenarios

## Segfault master

### KubeDB
```
kubectl logs redis-cluster-3master-shard0-0
kubectl logs redis-cluster-3master-shard0-1
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep myself
kubectl get pods --all-namespaces -o jsonpath='{range.items[*]}{.metadata.name} ---------- {.status.podIP}:6379{"\n"}' | grep redis

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli DEBUG SEGFAULT

> - Pod restarts
  - Slave sees master is lost, tries to connect to master which fails
  - tries again: ok, replica ask for sync: Replica ID mismatch
  - Resync

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
```

### Redis-Cluster
```
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES
kubectl get pods -l app=redis-cluster -o wide

MASTER=rediscluster-cluster-b7vxk
REPLICA=rediscluster-cluster-t4pvd

kubectl exec $MASTER -- redis-cli CLUSTER NODES | grep self
kubectl exec $REPLICA -- redis-cli CLUSTER NODES | grep self

kubectl logs $MASTER
kubectl logs $REPLICA

kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master
kubectl exec $MASTER -- redis-cli DEBUG SEGFAULT
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master
kubectl logs $REPLICA

kubectl logs operator-redis-operator-c4497b-wjrsz

>> Result:
Master:  Redis segfault, redisnode catches this
         Liveness and Readiness failed during 5 min, then pod restart, as replica
         After ~6 sec: Connect to master, replica sync
         After another 6 sec: Sync finished
Replica: master lost
         after 2.9s, won election: new master
Operator: Sync with pods each 30s
          0-30s after:
            - Error when get cluster infos to rebuild bom : Cluster view is inconsistent
            - Unable to retrieve the associated Redis Node with the pod: rediscluster-cluster-b65x5,
              ip:10.244.3.2, err:node not founded
            - compare status.NbRedisRunning: 6 - 5
          Pod restarted:
            cluster-migration.go:23] Start dispatching slots to masters nb nodes: 6
            cluster-migration.go:36] Total masters: 4 - target 3 - selected: 3
            cluster-roles.go:54: [AttachingSlavesToMaster

          BUT still: Error when get cluster infos to rebuild bom : Cluster view is inconsistent
```



#### Manual cluster failover


# Triggers pod restart

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep myself

93ce690f54620d56737fa45bf57acff18acd900e 10.244.3.5:6379@16379 master - 0 1593428797197 2 connected 5461-10922
bf742a3cc4cdc2850b55f49cf387e2b84fd27ac6 10.244.3.7:6379@16379 slave 1af64f33f7e74399ada01f1e831eee0bdb3488ac 0 1593428796000 3 connected
d95d5c151d12d4b3702f3dc97f00033c84d4fd40 10.244.2.5:6379@16379 slave 93ce690f54620d56737fa45bf57acff18acd900e 0 1593428796595 2 connected
8f3d50f6e23cedaa61c209955b6bb88c683f1730 10.244.2.3:6379@16379 myself,master - 0 1593428796000 1 connected 0-5460
1af64f33f7e74399ada01f1e831eee0bdb3488ac 10.244.1.4:6379@16379 master - 0 1593428796194 3 connected 10923-16383
d34c6f6fce58e58c7dfc605788bbe34bdc3141d1 10.244.3.3:6379@16379 slave 8f3d50f6e23cedaa61c209955b6bb88c683f1730 0 1593428797000 1 connected




# Redis-Operator commands
kubectl get pods -l app=redis-cluster -o wide



# KubeDB commands

# Get Redis versions
kubectl get redisversions

## Get operator log
kubectl -n kube-system logs -l app=kubedb --tail 10000

## Check status of pod
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli CLUSTER NODES | grep myself

## Get Redis config
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli config get \*

## Get log
kubectl logs redis-cluster-3master-shard0-0

# Get Redis cluster config
kubectl describe configmap/redis-cluster-3master

# Enter shell
kubectl exec -it redis-cluster-3master-shard0-0 -- sh

# Install Weave Scope

```
kubectl apply -f "https://cloud.weave.works/k8s/scope.yaml?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl port-forward -n weave "$(kubectl get -n weave pod --selector=weave-scope-component=app -o jsonpath='{.items..metadata.name}')" 4040

xdg-open http://localhost:4040
```


# Install redis-cli
wget -c http://download.redis.io/redis-stable.tar.gz -O - | tar -xz -C /tmp
make -C /tmp/redis-stable
cp /tmp/redis-stable/src/redis-cli ~/bin/
chmod 755 ~/bin/redis-cli

# Get all versions available
$ kubectl get redisversions -n kube-system  -o=custom-columns=NAME:.metadata.name,VERSION:.spec.version,DB_IMAGE:.spec.db.image,TOOLS_IMAGE:.spec.tools.image,EXPORTER_IMAGE:.spec.exporter.image,DEPRECATED:.spec.deprecated
