
Workloadのリソースとして以下が存在する

* Deployments
* ReplicaSet
* StatefulSets
* DaemonSet
* Jobs
* Automatic Cleanup for Finished Jobs
  * A time-to-live mechanism to clean up old Jobs that have finished execution.
* CronJob
* ReplicationController

## ## [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)

## ## [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/)

## ## [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

## ## [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

DaemonSetはノードがPodの"copy"を動作させることを保証する。ノードがクラスターに登録されたタイミングで、Podsはそのノードに追加される。また、ノードがクラスターから削除された際はそれらのPodsはガーベージコレクションされる。DaemonSetを削除することはDaemonSetによって作成されたPodsを削除することと同等である。

__DaemonSetの典型的なユースケースは以下である。__

* 各ノードに、クラスターストレージのデーモンを動作させる
* 各ノードに、ログ収集用のデーモンを動作させる
* 各ノードに、ノード監視用のデーモンを動作させる

シンプルな使い方では、1つのDaemonSetがすべてのノードでそれぞれの特定の機能のために動作する。複雑な使い方では、複数のDaemonSetを利用して単一の機能のデーモンを構成し、このとき異なるflagやメモリ、CPUを異なるハードウェアタイプとして扱う。

### ### Writing a DaemonSet Spec

#### #### Create a DaemonSet

ここから

## ## [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)

## ## [Automatic Cleanup for Finished Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/ttlafterfinished/)

## ## [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)

## ## [ReplicationController](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/)