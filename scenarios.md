# Setup

### KubeDB
```
cd kubedb

# Setup K8s and KubeDB operator + catalog
./setup.sh

# Create Redis config
kubectl create configmap rd-custom-config --from-file=redis.conf=./cluster-config.conf
kubectl get configmap/rd-custom-config -o yaml

# Install DB (Redis 5.0.3)
kubectl apply -f demo_3master.yaml

# Fill with data (!! Update REDIS_HOST ENV)
make -C ~/git/redis-job run
kubectl get jobs

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

kubectl exec rediscluster-cluster-p6zml -- redis-cli DBSIZE
kubectl exec rediscluster-cluster-rqlxq -- redis-cli DBSIZE
kubectl exec rediscluster-cluster-f9gj4 -- redis-cli DBSIZE
```

## Scenarios

### Segfault master (3 master setup)

#### KubeDB
```
kubectl logs redis-cluster-3master-shard0-0
kubectl logs redis-cluster-3master-shard0-1
kubectl get pods

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli DEBUG SEGFAULT
kubectl get pods
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
kubectl describe statefulset redis-cluster-3master-shard0

kubectl exec -it redis-cluster-3master-shard0-0 -- sh

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli DBSIZE
kubectl exec redis-cluster-3master-shard1-0 -- redis-cli DBSIZE
kubectl exec redis-cluster-3master-shard2-0 -- redis-cli DBSIZE

>> Result:
1. cluster-node-timeout 2000, mounted nodes.conf (Mounted as EmptyDir)
  - Every second restart: Master pod restarts, understands it was master before
  - Replica sees master is lost, tries to connect to master, connects second time
  - Master sync empty DB to replica....

2. cluster-node-timeout 1
  - Pod restarts
  - Replica takes over as master

* statefulset-controller not affected
* operator not affected
* Since data is mounted as EmptyDir, its kept across container crashes.
  This might be the reason for not failing over
* Using /tmp as place to store nodes.conf makes sure it is re-created when container crash
  But the IP for "self" is missing since the fix-ip.sh uses /data
  It seems that an EmptyDir/Storage mount is required for nodes.conf
* Restart a node and loosing nodes.conf might not work with Redis Cluster
  -or-
  its missing the ip?
```

#### Redis-Cluster
```
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES
kubectl get pods -l app=redis-cluster -o wide

MASTER=rediscluster-cluster-qh2hs
REPLICA=rediscluster-cluster-6lm92

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

### Pod delete - graceful deletion of Master (3 master setup)

kubectl delete pods <pod>

#### KubeDB
```
kubectl logs redis-cluster-3master-shard0-0
kubectl logs redis-cluster-3master-shard0-1

kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
kubectl exec redis-cluster-3master-shard0-1 -- redis-cli cluster nodes | grep master
kubectl get pods
time kubectl delete pod redis-cluster-3master-shard0-0
kubectl get pods
kubectl exec redis-cluster-3master-shard0-0 -- redis-cli cluster nodes | grep master
kubectl exec redis-cluster-3master-shard0-1 -- redis-cli cluster nodes | grep master

kubectl logs redis-cluster-3master-shard0-0
kubectl logs redis-cluster-3master-shard0-1

kubectl describe statefulset redis-cluster-3master-shard0

kubectl logs -n kube-system kubedb-operator-74dc7d69c5-t6kt7

>> Result:
cluster-node-timeout 2000:
     Command: command takes 2-11 sec
 1. Using EmptyDir mounted as /data => nodes.conf is lost
    -> Pod get new IP
    -> Missing IP for self
    -> only myself in nodes.conf
    -> replica tells: master, fail for old IP
 2. Using permanent storage for /data => nodes.conf is resilient
    -> Pod get new IP
    -> IP address for Redis instance differs between instances..
       both nodes.conf and CLUSTER SLOTS..
    -> Master still master, keys lost in old master

cluster-node-timeout 1:
 1. Using EmptyDir mounted as /data => nodes.conf is lost
    -> Pod get new IP
    -> Missing IP for self
    -> only myself in nodes.conf
    Keys lost in old master
 2. Using permanent storage for /data => nodes.conf is resilient
    -> Master:  the statefulset-controller restarts pod, become new replica
    -> Replica: Connection with master lost. (1 to 3.5) sec later: become new master
    -> Operator: nothing

```

#### Redis-Cluster
```
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES
kubectl get pods -l app=redis-cluster -o wide

MASTER=rediscluster-cluster-p6zml
REPLICA=rediscluster-cluster-fphfh

kubectl exec $MASTER -- redis-cli CLUSTER NODES | grep self
kubectl exec $REPLICA -- redis-cli CLUSTER NODES | grep self

kubectl logs $MASTER
kubectl logs $REPLICA

kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master
kubectl get pods
time kubectl delete pod $MASTER
kubectl get pods
kubectl exec service/cluster-redis-cluster -- redis-cli CLUSTER NODES | grep master

kubectl logs operator-redis-operator-c4497b-6dwl7

>> Result:
- Delete command takes ~3 sec
- Replica: Manual failover requested before lost connection with master
- No keys lost
- After 20s new pod is up and synced as replica node

```

### Pod delete - force delete of Master (3 master setup)

kubectl delete pods <pod> --grace-period=0 --force

#### KubeDB
```
```

#### Redis-Cluster
```
```




### Manual cluster failover



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

# Get pods with IPs
kubectl get pods --all-namespaces -o jsonpath='{range.items[*]}{.metadata.name} ---------- {.status.podIP}:6379{"\n"}' | grep redis

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
