# Inspect a cluster

## Redis-Cluster

```
k describe rediscluster cluster

Status:
  Cluster:
    Max Replication Factor:  1
    Min Replication Factor:  1
    Nb Pods:                 6
    Nb Pods Ready:           6
    Nb Redis Nodes Running:  6
    Nodes:
      Id:        c8969ac4c3a14af4e6e34c50048d9537f6874cc2
      Ip:        10.244.1.3
      Pod Name:  rediscluster-cluster-28thm
      Port:      6379
      Role:      Master
      Slots:
        5462-10923
      Id:        aae386ace0f583503d8283f62e7a17c789f8ce55
      Ip:        10.244.3.2
      Pod Name:  rediscluster-cluster-bm7j2
      Port:      6379
      Role:      Master
      Slots:
        10924-16383
      Id:          ae0b22e404d95f1ed0d4909795102ed894ddbf31
      Ip:          10.244.2.3
      Master Ref:  c8969ac4c3a14af4e6e34c50048d9537f6874cc2
      Pod Name:    rediscluster-cluster-6cqvm
      Port:        6379
      Role:        Slave
      Id:          453af12b069be4f3840f9c189c65645711d89061
      Ip:          10.244.3.3
      Master Ref:  485e79f3763625266ddf2d5d5a6d409c413b3aa8
      Pod Name:    rediscluster-cluster-5m5sm
      Port:        6379
      Role:        Slave
      Id:          bc93e2501f95b1e2071ce998f663bc6c7c43e565
      Ip:          10.244.1.4
      Master Ref:  aae386ace0f583503d8283f62e7a17c789f8ce55
      Pod Name:    rediscluster-cluster-64xfk
      Port:        6379
      Role:        Slave
      Id:          485e79f3763625266ddf2d5d5a6d409c413b3aa8
      Ip:          10.244.2.2
      Pod Name:    rediscluster-cluster-mtmdn
      Port:        6379
      Role:        Master
      Slots:
        0-5461
    Number Of Master:  3
    Status:            OK
  Conditions:
    Last Probe Time:       2020-09-01T09:08:00Z
    Last Transition Time:  2020-09-01T09:08:00Z
    Message:               cluster needs more pods
    Reason:                cluster needs more pods
    Status:                False
    Type:                  Scaling
    Last Probe Time:       2020-09-01T09:06:04Z
    Last Transition Time:  2020-09-01T09:06:04Z
    Message:               reconfigure on-going after topology changed
    Reason:                topology as changed
    Status:                False
    Type:                  Rebalancing
    Last Probe Time:       2020-09-01T09:06:04Z
    Last Transition Time:  2020-09-01T09:06:04Z
    Message:               a Rolling update is ongoing
    Reason:                Rolling update ongoing
    Status:                False
    Type:                  RollingUpdate
    Last Probe Time:       2020-09-01T09:06:04Z
    Last Transition Time:  2020-09-01T09:06:04Z
    Message:               redis-cluster is correctly configure
    Reason:                redis-cluster is correctly configure
    Status:                True
    Type:                  ClusterOK
  Start Time:              2020-09-01T09:06:04Z
  Status:
Events:                    <none>
```


## KubeDB

```
k describe redis.kubedb.com/redis-cluster-3master

Status:
  Observed Generation:  1$6208915667192219204
  Phase:                Running
Events:                 <none>
```
