# Chaos testing

## Redis-Cluster
```
cd <repo root>
redis-cluster/setup.sh
make -C tools/redis-job run
```

### Delete service
- Service re-created, most likely by operator

### Delete pod
- Operator not able to connect to redis cli
- Operator starts a new one

### Modify CRD
- Operator triggerd, restart pods



--------------------------------------------------------------------------------

## KubeDB

```
cd <repo root>
kubedb/setup.sh
kubectl apply -f kubedb/demo_3master.yaml
```

### Delete governing service
- Service gone
- no action from operator

### Delete clusterip service
- Service gone
- no action from operator

### Delete statefulset / shard
- Statefulset and pods gone
- redis cluster fail
- no action from operator

NAMESPACE   NAME                                     VERSION    STATUS    AGE
default     redis.kubedb.com/redis-cluster-3master   5.0.3-v1   Running   39m

### Modify CRD
- Operator triggerd
- Services and statefulsets re-created

### Delete pod
- Statefulsets re-creates pod
- no action from operator
