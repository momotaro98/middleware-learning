## ## [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)

### ### Management

#### #### Node name uniqueness

ノードの名前(name)は必ずユニークにする必要があり、かつ __名前はネットワーク設定やrootディスクにも紐づく__。そのため、名前の変更無しにノードインスタンスを変更すると設定上の不整合につながる。したがって、ノードを更新する際は既存のノードはK8s APIによって削除し新規にノードを追加する必要がある。

#### #### Self-registration of Nodes

kubeletのフラグである`--register-node`がtrueのとき(デフォルトがtrue)、kubeletは自身をK8sのAPIを通して登録する。self-registrationにおいて、kubeletは以下のオブションでキックされる。

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

#### #### Manual Node administration

ここから(このファイルの章はインフラよりなので一旦飛ばす)