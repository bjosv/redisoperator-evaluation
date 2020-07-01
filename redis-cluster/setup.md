# Redis Cluster in K8s

```
# 1.17.5 - no matches for kind "Deployment" in version "extensions/v1beta1"
# 1.16.9 - no matches for kind "Deployment" in version "extensions/v1beta1"   - Deprecated 1.16
kind create cluster --image kindest/node:v1.15.11 --config ./kind_multinode.yaml

# Install the operator (Helm3)
helm install operator ~/go/src/github.com/amadeusitgroup/redis-operator/chart/redis-operator
```

### Creates

1 pod
1 deployment: operator-redis-operator
1 replicaset
1 CRD: redisclusters.redisoperator.k8s.io


# Install DB

```
helm install cluster ./redis-cluster
```

### Creates
6 pods    : cluster pods: "Controlled By:  RedisCluster/cluster", prio:0
1 service : port 6379
1 configmap: redis.conf       : redis config


### Pod inspect
kubectl exec -it rediscluster-cluster-6gr2q -- sh
kubectl exec -it rediscluster-cluster-6gr2q -- redis-cli cluster nodes

redisnode --v=6 ....
  -> starts redis-server /redis-conf/redis.conf




# OLD

```
# Start K8s if needed
kind create cluster

# Make sure we delete old PersistentVolumeClaims
kubectl delete pvc -l app=redis-cluster

# Start pods
kubectl apply -f redis-cluster.yaml

# Wait for 6 running pods
kubectl get pods
kubectl get pv
kubectl logs redis-cluster-0

# Join cluster
kubectl exec -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 \
$(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')

# Enter yes

# Check masters/slaves
kubectl exec redis-cluster-0 -- redis-cli cluster nodes
```

## Scale up

```
# Add 2 nodes
kubectl scale statefulset redis-cluster --replicas=8
kubectl get pods

# Add new master
kubectl exec redis-cluster-0 -- redis-cli --cluster add-node \
$(kubectl get pod redis-cluster-6 -o jsonpath='{.status.podIP}'):6379 \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Add new slave (will automatically be slave to new master)
kubectl exec redis-cluster-0 -- redis-cli --cluster add-node --cluster-slave \
$(kubectl get pod redis-cluster-7 -o jsonpath='{.status.podIP}'):6379 \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Rebalance masters (moving slots to new)
kubectl exec redis-cluster-0 -- redis-cli --cluster rebalance --cluster-use-empty-masters \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379
```

## OPTIONAL: Scale up again

```
# Add 2 nodes
kubectl scale statefulset redis-cluster --replicas=10
kubectl get pods

# Add new master
kubectl exec redis-cluster-0 -- redis-cli --cluster add-node \
$(kubectl get pod redis-cluster-8 -o jsonpath='{.status.podIP}'):6379 \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Add new slave (will automatically be slave to new master)
kubectl exec redis-cluster-0 -- redis-cli --cluster add-node --cluster-slave \
$(kubectl get pod redis-cluster-9 -o jsonpath='{.status.podIP}'):6379 \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Rebalance masters (moving slots to new)
kubectl exec redis-cluster-0 -- redis-cli --cluster rebalance --cluster-use-empty-masters \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

kubectl exec redis-cluster-0 -- redis-cli cluster nodes
```

## Crash instance

```
kubectl exec redis-cluster-0 -- redis-cli debug segfault
```

## Scale down
```
# Get ID/hash of master to scale down
MASTER=$(kubectl exec redis-cluster-6 -- redis-cli cluster nodes | grep myself | cut -f 1 -d " ")

# Get ID/hash of other masters
kubectl exec redis-cluster-6 -- redis-cli cluster nodes | grep master | grep -v myself

# Reshard
kubectl exec redis-cluster-0 -- redis-cli --cluster reshard --cluster-yes \
--cluster-from 6c4aad013bcebb9fb1f4c2d87c7c6a797091e30b \
--cluster-to 3a8b8ad4ad7d22dfab6b50a73e060b1c0beb789f \
--cluster-slots 16384 \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Remove master from list (pod will restart)
kubectl exec redis-cluster-0 -- redis-cli --cluster del-node \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379 \
6c4aad013bcebb9fb1f4c2d87c7c6a797091e30b

# Rebalance remaining masters
kubectl exec redis-cluster-0 -- redis-cli --cluster rebalance --cluster-use-empty-masters \
$(kubectl get pod redis-cluster-0 -o jsonpath='{.status.podIP}'):6379

# Scale back/down
kubectl scale statefulset redis-cluster --replicas=6
kubectl get pods

```
