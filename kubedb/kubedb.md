# KubeDB background

https://poddtoppen.se/podcast/1193040557/data-engineering-podcast/running-your-database-on-kubernetes-with-kubedb
Mon, 29 Apr 2019

* Started with a deployment platform
* Running K8s, Found gaps, built own toolings, then open sourced late 2017
* Greenfielders, only likes to support 1 stack (Benefit: monitoring, LCM, operations)
* DB, backups local disks
* Main challanges: stateful system, Ip changes, StatefulSet=fixed hostname, but still new IP
* KubeDB: operator pattern, collection of CRDs, each DB-type has its own CRD
* Start pod, issue storage space req.,..the respond DB is reasy.
* 1 operator for each DB-type, put into single binary, in one docker
* Started 2016 (no CRD) used Third Party Resource (TPR),
  then switch from Deployment to StatefulSet (static hostname, specific number of replicas)
  CRD migration in 1.13
* Painpoints addressed: bring up a DB (service, config
  - Failover
  - Automated backup (every 4,6,.. hours), recover from backup
  - User management support, use Vault to add users (KubeVault) Cloud provider secrets
* LCM: Upgrade of DB version: not supporting major version upgrades
       minor version upgrade, not automatically supported (Might come in future!)
       Redis: Upgrade replicas first,primary at the end... do it manually.
       Rolling upgrade not intelligent
* Support new DB: CRD, copy existing DB. Use existing DB docker image
  apimachinery: CRD, clients
* Other projects:
  - StorageOS - more like Rook (not a application layer)
  -
* Biggest challange:
  - speed of change in some areas
  - pod security updates
  - Some things is slow 9month from Alpha,Beta,GA
  - Docs when writing for K8s (read code), time to learn
* Future: (3-6 month)
 - Clustering support for mongodb, ..
 - Update backup, recovery: 1.0
 - CLI today, Web interface
 - New DBs

* Service broker (Cloud foundry)

## Reviews

https://www.reddit.com/r/kubernetes/comments/e97j33/is_kubedb_ready_for_production/

## Containers:

https://hub.docker.com/r/kubedb/operator/tags
