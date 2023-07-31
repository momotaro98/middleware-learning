# # [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

## ## [Pod Lifecycle]()

TODO

## ## [Init Containers]()

TODO

## ## [Disruptions]()

TODO

## ## [Ephemeral Containers]()

TODO

## ## [Pod Quality of Service Classes](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos/)

### ### Quality of Service classes

K8sはPodを quality of service (QoS) class という単位で分類する。
コンテナに設定される[resource request](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)に基づいてK8sはQoSの分類をする。
[Node Pressure](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/)を受けているNodeにて、QoSによってK8sはどのPodを取り除く(evict)かを決定する。
QoSのタイプとして、`Guaranteed`, `Burstable`, `BestEffort` がある。ノードがリソース不足に陥ったとき、K8sはまず`BestEffort`からevictし、つづいて`Burstable`、最後に`Guaranteed`になる。

設定方法 → https://kubernetes.io/docs/tasks/configure-pod-container/quality-service-pod/

## ## [User Namespaces]()

TODO

## ## [Downward API]()

TODO