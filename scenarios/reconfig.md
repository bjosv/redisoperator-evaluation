# Reconfig redis (trace)

## Redis-Cluster
```
cd <repo root>
redis-cluster/setup.sh

# Fill with data
make -C tools/redis-job run
kc nodes

# Check operator is ok
k logs operator-redis-operator-xxxxx
```

### Modify Redis config

Change of configmap

```
k get pods -A
k describe configmap/cluster
k logs rediscluster-cluster-8s2hx

# Change loglevel
k edit configmap/cluster
```

- no effect!! operator is not watching for changes in configmap
- One solution is to manually kill pod

### Change log level in CRD

```
# View status
k logs operator-redis-operator-xxxx
k describe rediscluster cluster

# Edit redis config
k edit configmap/cluster

# Edit log level, set  log:level: 11
k edit rediscluster cluster

-or-

# Modify values.yaml, set  log:level: 11
helm upgrade cluster charts/redis-cluster
```
Operator restarts pods, but very often parts of key gone!

### Change log level in operator

```
k logs operator-redis-operator-c4497b-9lg7b

# Change -v
k edit deployments operator-redis-operator
```
Operator pod terminated, new started
```

--------------------------------------------------------------------------------

# KubeDB

```
cd <repo root>
kubedb/setup.sh

# Check operator is ok
k get pods -A
k logs -n kube-system kubedb-operator-74dc7d69c5-t68nv

kubectl apply -f kubedb/demo_3master.yaml

kc nodes
```

### Modify Redis config

Change of configmap

```
# Set a key
kubectl exec pod/redis-cluster-3master-shard2-0 -- redis-cli SET key value
kc nodes

k logs redis-cluster-3master-shard2-0

# Change loglevel
k edit configmap/rd-custom-config

# Restart pod, will use new log-level
k delete pod redis-cluster-3master-shard2-0

k logs redis-cluster-3master-shard2-0

kubectl exec pod/redis-cluster-3master-shard2-0 -- redis-cli GET key
kubectl exec pod/redis-cluster-3master-shard2-1 -- redis-cli GET key

```

- Just chaning the configmap:
  no effect!! operator is not watching for changes in configmap

- One solution is to manually kill pod

### Change log level in operator

```
k edit deployments -n kube-system kubedb-operator
```
New operator started, old one killed



### Conclusion

* Change redis config, manual pod terminated needed
* Operator config changes
  - Amadeus chart has default strategy: recreate, first stop then start
  - KubeDB uses K8s default: rolling update (uses readinessProbe)

!!! To avoid killed master to take over again
!!! Needs to change
#cluster-node-timeout 2000
cluster-node-timeout 1

!!! Durable storage (default)
nodes.conf mounted into newly started pod
IP wrong...

!!! Ephemeral storage
No cluster config found (nodes.conf), i.e gets new ID
(since it got a new IP, it cant talk to cluster)


- KubeDB:
K8S_VERSION=v1.16.9
  replicas: 1
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate

- Redis-Operator
K8S_VERSION=v1.15.11
  replicas: 1
  strategy:
    type: Recreate
