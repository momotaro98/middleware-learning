# # [Extending Kubernetes](https://kubernetes.io/docs/concepts/extend-kubernetes/)



## ## [Compute, Storage, and Networking Extensions](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/)

### ### [Network Plugins](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)

Kubernetes supports [Container Network Interface](https://github.com/containernetworking/cni) (CNI) plugins for cluster networking.   
用途に合うクラスターと整合するCNI pluginを利用しなければなりません。  
Different plugins are available (both open- and closed- source) in the wider Kubernetes ecosystem.

CNI pluginは[Kubernetes Network model](https://kubernetes.io/docs/concepts/services-networking/#the-kubernetes-network-model)を実装する必要がある。