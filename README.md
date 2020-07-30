# Evaluation of Redis Cluster operators

* [AmadeusITGroup/Redis-Operator](https://github.com/AmadeusITGroup/Redis-Operator) master/f651441
* [KubeDB](https://github.com/kubedb) v0.13.0-rc.0


## Scenarios

Behaviours in following scenarios have been investigated:

* [Reconfigure Redis and operator](scenarios/reconfig.md)
* Segfault master (3 master setup)
* Pod delete - graceful deletion of Master (3 master setup)
* Pod delete - force delete of Master (3 master setup)
* Manual cluster failover

* Crash pid 1 in master pod (3 master setup)
