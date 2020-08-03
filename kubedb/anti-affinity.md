
See:
https://github.com/kubernetes/community/blob/master/contributors/design-proposals/scheduling/podaffinity.md

- Pod anti-affinity requires nodes to be consistently labelled
- every node in the cluster must have an appropriate label matching topologyKey.

nodeSelector

spec:
  affinity:
    nodeAffinity:
    podAffinity:
    podAntiAffinity:


// Prefer to not schedule multiple pods on the same node
// Prefer to not schedule multiple pods on the node with same zone
Given: Namespace = which namespace the redis pods are in)
Given: Labels    = ..... (Label selector)
Topology domain: Hostname  corev1.LabelHostname: "kubernetes.io/hostname"
Topology domain: Zone      topology.LabelZone    K8s >= 1.17: "topology.kubernetes.io/zone"
                                                 K8s <  1.17: "failure-domain.beta.kubernetes.io/zone"
See:
~/git/kubedb/apimachinery/apis/kubedb/v1alpha1/redis_helpers.go

k get nodes -o yaml
