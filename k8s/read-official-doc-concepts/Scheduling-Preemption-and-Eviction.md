


## ## [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

Podを特定のノードでRunするように制御することができる。その方法はいくつかありrecommendedなのはlabel selectorsを使うことである。たいていはスケジューラにPodの配置を任せることができる。しかし、Podの配置のノード先を制御したい状況がいくつかあるだろう。例えば、特定のPodをSSDがアタッチされたノードに配置したいとか、異なるサービスのPod2つを同じAvailability Zoneに配置してコミュニケーション負荷を緩和したいなどである。

以下の方法を使ってK8sがPodスケジュールする場所を選ぶことができる

* nodeSelector field matching against node labels
* Affinity and anti-affinity
* nodeName field
* Pod topology spread constraints

### ### [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)

`nodeSelector`は最もシンプルでrecommendedなノード選択制御の方法である。node labelsを特定させることでPodを配置するノードを制御できる。

[Assign Pods to Nodes](https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/) に詳細がある。

### ### [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)

`nodeSelector`は最もシンプルである。Affinityとanti-Affinityは制御の幅がより広い。Affinityとanti-Affinityの利点は以下である。

* より拡張的である。nodeSelectorはラベルでしか制御できないがAffinityはより複雑に制御を設定できる
* ルールの厳しさを調整できる。
* node labelだけでなく、他のPodのlabelを使ってPod配置の制御ができる。

#### #### Node affinity

2つのnode affinityのタイプがある。

* `requiredDuringSchedulingIgnoredDuringExecution`: スケジューラはルールが満たされるまでPodを配置することができない。(厳しい設定)。
* `preferredDuringSchedulingIgnoredDuringExecution`: もし対応するノードが見つからなくてもPodを配置する。(ゆるい設定)。

> Note: 上記にある`IgnoredDuringExecution`は、KubernetesがPodをスケジュールした後にNodeラベルが変更されても、Podは実行し続けることを意味します。

例えば、次のようなPodのspec(仕様)を考えてみましょう:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: topology.kubernetes.io/zone
            operator: In
            values:
            - antarctica-east1
            - antarctica-west1
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: another-node-label-key
            operator: In
            values:
            - another-node-label-value
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
```

> `operator`フィールドを使用して、Kubernetesがルールを解釈する際に使用できる論理演算子を指定することができます。`In`、`NotIn`、`Exists`、`DoesNotExist`、`Gt`、`Lt`が使用できます。

> `NotIn`と`DoesNotExist`を使って、NodeのAnti-Affinity動作を定義することができます。また、[NodeのTaint](https://kubernetes.io/ja/docs/concepts/scheduling-eviction/taint-and-toleration/)を使用して、特定のNodeからPodをはじくこともできます。

Note:

> nodeSelectorとnodeAffinityの両方を指定した場合、__両方の条件を満たさないと__ PodはNodeにスケジュールされません。

> nodeAffinityタイプに関連付けられた __nodeSelectorTerms内に複数の条件__ を指定した場合、Podは指定した条件のいずれかを満たしたNodeへスケジュールされます(__条件はORされます__)。

> nodeSelectorTerms内の条件に関連付けられた1つの __matchExpressionsフィールド内に複数の条件__ を指定した場合、Podは全ての条件を満たしたNodeへスケジュールされます(__条件はANDされます__)。