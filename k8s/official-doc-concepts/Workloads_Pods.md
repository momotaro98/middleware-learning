# # [Pods](https://kubernetes.io/docs/concepts/workloads/pods/)

## ## [Pod Lifecycle]()

TODO

## ## [Init Containers]()

TODO

## ## [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

### ### Voluntary and involuntary disruptions (意図的/非意図的なDisruption)

避けることができないような非意図的なDisruptionには以下の例がある。

* a hardware failure of the physical machine backing the node
* cluster administrator deletes VM (instance) by mistake
* cloud provider or hypervisor failure makes VM disappear
* a kernel panic
* the node disappears from the cluster due to cluster network partition
* eviction of a pod due to the node being [out-of-resources](https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/).

一方で、意図的なDisruptionがある。これらはアプリケーション管理者のActionで引き起こされるものと、クラスター管理者によって引き起こされるものがある。

典型的なアプリケーション管理者によるvoluntary disruptionは以下がある。

* Podを管理するDeploymentまたは他のコントローラーを削除してしまう
* リスタートを伴うようなDeploymentのPodテンプレートを更新してしまう
* 直接Podを削除してしまう(e.g. 偶然にも)

クラスター管理者によるvoluntary disruptionは以下がある。

* 修正またはアップグレードのためにノードをDrainしてしまう
* クラスターをスケールダウン(?)させるためにノードをDrainしてしまう (learn about Cluster Autoscaling ).
* 何か他の作業を対象ノードで実施するためにPodを対象ノードから削除してしまう

【注意】
すべてのvoluntary(意図的)DisruptionがPod Disruption Budgetsに守られるわけではない！例えば、DeploymentやPodを削除することはPod Disruption Budgetsを通過する(無視する)

### ### Dealing with disruptions

disruptionsに関する各クラスターのProviderのドキュメントを確認しておくこと。(GKE、EKS、AKS、VKS)

### ### [Pod disruption budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets)

> As an application owner, you can create a PodDisruptionBudget (PDB) for each application. A PDB limits the number of Pods of a replicated application that are down simultaneously from voluntary disruptions.

ここから
todo

### ### PodDisruptionBudget example

todo

### ### Pod disruption conditions

todo

### ### Separating Cluster Owner and Application Owner Roles

todo

### ### How to perform Disruptive Actions on your Cluster

todo

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