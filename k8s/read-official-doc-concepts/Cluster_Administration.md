
## ## Cluster Networking

動的なポート割当てはシステムに複雑さを生む。APIサーバは動的ポート数を設定ブロックにInsertする方法をh知っている必要があり、serviceはお互いを見つける方法を知っている必要がある。  
そうではなく、Kubernetesは異なるアプローチを取る。  
K8sのネットワークモデルを学ぶ場合は、[here](https://kubernetes.io/docs/concepts/services-networking/)を参照すること。

### ### How to implement the Kubernetes network model

そのネットワークモデルは各ノード上のコンテナランタイムによって実装されている。最も標準なコンテナランタイムは [Container Network Interface (CNI)](https://github.com/containernetworking/cni) plugins を利用しネットワークとセキュリティキャパシティを管理する。多くの異なったCNI pluginが各ベンダーごとに存在している。

See [this page](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy) for a non-exhaustive list of networking addons supported by Kubernetes.