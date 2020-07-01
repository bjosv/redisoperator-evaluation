# Redis Cluster in K8s

Comparison runs

```
kind create cluster --image kindest/node:v1.17.5 --config ./kind_multinode.yaml

# Install the operator
helm install --name operator ~/go/src/github.com/amadeusitgroup/redis-operator/chart/redis-operator


```


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
