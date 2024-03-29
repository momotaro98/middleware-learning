## ## [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)

### ### Management

#### #### Node name uniqueness

ノードの名前(name)は必ずユニークにする必要があり、かつ __名前はネットワーク設定やrootディスクにも紐づく__。そのため、名前の変更無しにノードインスタンスを変更すると設定上の不整合につながる。したがって、ノードを更新する際は既存のノードはK8s APIによって削除し新規にノードを追加する必要がある。

#### #### Self-registration of Nodes (推奨)

kubeletのフラグである`--register-node`がtrueのとき(デフォルトがtrue)、kubeletは自身をK8sのAPIを通して登録する(推奨)。self-registrationにおいて、kubeletは以下のオブションでキックされる。

* `--kubeconfig` - K8s APIを叩くための認証情報へのパス
* `--cloud-provider` - Cloud Provider情報
* `--register-node` - 自動で登録するかのフラグ(デフォルトがtrue)
* `--register-with-taints` - Register the node with the given list of taints (comma separated <key>=<value>:<effect>).  * No-op if register-node is false. (2023年1月31日時点で意味が不明)
* `--node-ip` - 対象ノードのIPアドレス
* `--node-labels` - ノードがクラスタに登録される際にセットするラベル
* `--node-status-update-frequency` - kubeletが対象ノードのステータスをK8s APIサーバへ通知する頻度

[Node authorization mode](https://kubernetes.io/docs/reference/access-authn-authz/node/) と [NodeRestriction admission plugin](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#noderestriction) がEnabledのとき、kubeletは自分自身のノードリソースを作成/変更することのみ許された状態になる。

> Note: 上記のNode name uniquenessの箇所でも説明したように、ノード設定はノード名に紐づく。そのため、kubeletが再稼働した際にノード名が同じならば設定は同じになる。`--node-labels`が変更された場合はそれが適用される。
> 
> ノード設定がkubelet再起動時に変更されているならば、ノード上で既存でスケジュールされたPodは問題を引き起こす可能性がある。
> (2023年1月31日時点で理解できない) For example, already running Pod may be tainted against the new labels assigned to the Node, while other Pods, that are incompatible with that Pod will be scheduled based on this new label. Node re-registration ensures all Pods will be drained and properly re-scheduled.

#### #### Manual Node administration (非推奨)

kubectlを使ってNodeを作成することができる。(非推奨)

手動でNodeを作成したい場合は _kubelet_ の設定フラグで`--register-node=false`にしておくこと。

_kubelet_ の`--register-node`設定に関わらず既存のNodeの更新はできる。例えば、既存のノードにラベルを設定したり、"unschedulable"に設定できる。

Nodeオブジェクトに付いたラベルを使ってPodのNode Selectorの機能によってスケジューリングを制御することができる。例えば、特定のPodが特定のNode群でしかRunしないようにすることができる。

Nodeを"unschedulable"に設定することはK8sのスケジューラが新しいPodをそのNodeに配置することを防ぎ、一方でそのノードの既存のPodには影響を与えない。"unschedulable"への設定はノードをRebootしたりメンテナンスモードにする前の準備ステップとして便利である。

"unschedulable"に設定するには以下を実行する。

```
kubectl cordon $NODENAME
```

[Safely Drain a Node](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)のタスクページにて上記の操作の詳細を確認できる。

> Note: [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)の一部であるPodは"unschedulable"設定に関係なくそのノードで動く。たとえあるノードがWorkloadからdrainedされていてもDaemonSetは"node-local services"を提供することでそのノード上で動作するべきであるように設計されている。

### ### Node status

ここから