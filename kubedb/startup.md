# Start of operator creates:
1 deployment
1 replicaset
1 pod
1 service

# Start of Redis DB creates in namespace: demo
6 pods
2 services (1 gov + 1 DB)
3 statefulsets (2 pod each)
1 appbinding
1 redis

# Start of Redis DB 2: (4 instance)
8 pods
1 services (DB)
4 statefulsets (2 pod each)
1 appbinding
1 redis

# -------------------------------------

# operator
config.go
  rdc.New()
  rdCtrl.Init()
     - c.initWatcher() - Setup watcher and queue
                         Redis, Dormant and Snapshow watcher
run.go
  StartAndRunControllerss
RedisServerOptions.Run()
  rdCtrl.RunControllers()

# redis
redis/controller: RunControllers
  - rdQueue.Run(stopCh)

## workqueue.go
runRedis(key)    CRD!
- DeletionTimestamp?
 - Has finalizer?
no..
PatchRedis()   (See: apimachinery/client/clientset/versioned/typed/kubedb/v1alpha1/util/redis.go)
  Add finalizer

## redis.go
controller.create()
- validateRedis()
### admisson/validator.go
    // ValidateRedis checks if the object satisfies all the requirements.
- update status: Creating
- create governing service
  Create a redis sevice in namespace : name "kubedb"
- create redis config in configmap                             !!! Can be changed???
### redis_config.go
    createConfigMap
    patch redis: add config source
- ensure RBAC
### rbac.go
- ensure service
### service.go
    check and create service
- ensureRedisNodes (StatefulSet)
### statefulset.go
  - ensureStatefulSet, 1 per master
    - createStatefulSet
       - get redis version
       - parse affinity template
       - CreateOrPatchStatefulSet()
         ServiceName = GoverningService
         - Create pod (add redis and opt. exporter)    CHECK!!
    - get redis version
    - ConfigureRedisCluster
### configure-cluster/cluster.go
      - wait until servers ready   - wait for masters AND replicas, where is replias created?
          PING PONG all nodes
      - configure cluster state    - Redis configurations
        - ensureCluster
          - getOrderedNodes
            - ensureFirstPodAsMaster() - ensure first pos is master in Statefulset
              - getClusterNodes() - login to pod, run CLUSTER NODES
              - CLUSTER FAILOVER if not master
          - Make sure other is replicated from pod-0
          - ...
        - remove extra slaves
        - remove extra masters
        - add new masters
        - rebalance slots
        - add slaves
        - First pod is master
    - Check for remove masters(s)
    - Check for remove slaves(s)
- update redis status
- ensureStatsService
  make sure start/redis_exported is running
- manageMonitor
### monitor.go
- ensure AppBinding
  - appcatlog
## redis.go again


# OLD
server.go
 - server.New()
   - Setup EnableMutatingWebhook, EnableValidatingWebhook (ClusterTopology)
 Run() -> Controller:Run() and GenericContr
config.go
 - New()
   - detect toplogy
controller.go
 - Controller.New()
 - Controller.Init() -> initWatcher(): 
 - Controller.Run() -> StartAndRunControllers() -> queue.Worker.Run()
   -> workerqueue.go Controller.runRedis()
