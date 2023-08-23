# # Overview

## ## [K8sのコンポーネント](https://kubernetes.io/docs/concepts/overview/components/)

![image](https://d33wubrfki0l68.cloudfront.net/2475489eaf20163ec0f54ddc1d92aa8d4c87c96b/e7c81/images/docs/components-of-kubernetes.svg)

### ### Control Plane (コントロールプレーン) を構成する部品たち

コントロールプレーンは、クラスターに関する"global"な決定をする。Note:マスターノードに乗っかるソフト群

* kube-apiserver 
* etcd
* kube-scheduler
* kube-controller-manager
* cloud-controller-manager

#### #### kube-apiserver

API serverはK8s APIを提供するコントロールプレーンの部品の1つ。コントロールプレーンのフロントエンドにあたる。

API serverを主に実装しているのは、"kube-apiserver"という実装である。

#### #### etcd

すべてのクラスターデータを保持するキーバリュー(KV)ストア。一貫性と高い可用性の性質を持つ。

etcdを利用する場合は、データのために必ずバックアップのプラン・仕組みを持たせる必要がある。

#### #### kube-scheduler

PodをNodeに割り当てる判断を担う。それをスケジューリングと呼ぶ。

スケジューリングの要素になるのは、ハード・ソフトウェアの制約、"affinity", "anti-affinity"の設計、データロケーション、"inter-workload interference"、デッドライン などがある。

#### #### kube-controller-manager

[Note:重要そうでは無い気がするのでリンクだけ貼って省略](https://kubernetes.io/docs/concepts/overview/components/#kube-controller-manager) (以下 `Note:C` (Cutの略)と記載する)

#### #### cloud-controller-manager

cloud-controller-managerはAWS、GCPなどのクラウドプロバイダーのAPIとK8sクラスターをリンクさせる役割を持つ。

以降は[Note:C](https://kubernetes.io/docs/concepts/overview/components/#cloud-controller-manager)

### ### ノード を構成する部品たち

ノードはアプリケーションが動作するマシンのこと。Podを動かしK8sのランタイム環境を提供している。

* kubelet
* kube-proxy
* Container runtime

#### #### kubelet

各ノードにAgentとして動作する。コンテナがPod上で動作することを保証する役割を持つ。

kubeletはPodSpecsで記述された通りに動作することを保証するように動く。

#### #### kube-proxy

ノードごとに存在するネットワークプロキシ。K8sの"Service"の概念を担っている。

kube-proxyはノード上のネットワークのルールを管理している。Note:ファイアウォール的な役割である。

kube-proxyはOSのパケットフィルタリング層を利用している。

#### #### Container runtime

コンテナランタイムはコンテナ自体を動作させる役割を持つ。

K8sは [containerd](https://containerd.io/), [CRI-O](https://cri-o.io/) など、Kubernetes CRI (Container Runtime Interface) を実装する様々なコンテナランタイムをサポートしている。

### ### Addons

[Note:C](https://kubernetes.io/docs/concepts/overview/components/#addons)

## ## [The K8s API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)

API serverはK8sのコントロールプレーンの中で最も重要である。エンドユーザーやクラスターや外部コンポーネントがK8sリソースと通信する上で必要なAPIを提供している。

ほとんどの運用では`kubectl`か`kubeadm`のCLIを通してK8sのAPIを叩くことになるが、K8sのAPIをRESTのAPIとして直接呼ぶこともできる。

また、各プログラミング言語のクライアントライブラリも提供されており、それを通してK8sのAPIを叩くこともできる。 ( Go言語の場合 →  https://github.com/kubernetes/client-go/ )

### ### OpenAPI spec

K8sのAPIはOpenAPIで定義されていて確認することができる。

[Note:C](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#api-specification)

### ### 永続性 (Persistence)

K8sはシリアル化された状態(State)をetcdに書き込むことで保存している。

### ### API Extension

K8s APIは以下の2つの方法で拡張することができる。

1. [Custom resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
2. [Aggregation Layer](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/)

## ## Working with Kubernetes Objects

* Understanding Kubernetes Objects
* Kubernetes Object Management
* Object Names and IDs
* Labels and Selectors
* Namespaces
* Annotations
* Field Selectors
* Finalizers
* Owners and Dependents
* Recommended Labels

### ### [Understanding Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/#kubernetes-objects)

オブジェクトにはspecとstatusがありそれぞれがdesired statusとactual statusの意味。コントロールプレーンが常にactual statusをdesired statusにしようと試みる。

### ### [Kubernetes Object Management](https://kubernetes.io/docs/concepts/overview/working-with-objects/object-management/)

#### #### Management techniques

3種類ある。普通は*Declarative object configuration*で管理するはず。2つ目の*Imperative object configuration*がどういう用途なのか理解があまりできていない(2023年1月17日時点)

*Imperative commands* → ファイル無しでリソースを作る

`kubectl create deployment nginx --image nginx`

*Imperative object configuration* → 1つのファイルベースでリソース管理

`kubectl create -f one-file.yaml`, `kubectl replace -f one-file.yaml`, `kubectl delete -f one-file.yaml`

*Declarative object configuration* → ディレクトリ内の部分ごとのファイルでリソース管理可能

`kubectl diff -f configs/`, `kubectl apply -f configs/`


### ### [Object Names and IDs](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/)

#### #### Names

同じネームスペースでは同じ名前を"各リソース"では持てない。→ 同じネームスペースで`myapp-1234`という名前のPodは1つだけしか持てないが、Deploymentなどでそれぞれ同じ名前でも良い。

ユニークでは無い"文字列"を持たせるならば名前ではなくラベルとアノテーションが使える。

**K8sの"名前"はURLやDNSのサブドメインになり得るので各RFCの規格に沿うような文字を使う必要があるので注意**

#### #### UIDs

K8sが同様なリソースのライフサイクルを追えるように都度生成しているID。

K8sのUIDはUUIDsの一般的な規格に則っている。

### ### [Labels and Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/)

#### #### Syntax and character set

ラベルにはPrefixを`/`区切りでつけることができる。Prefixが無いときはそのラベルはユーザーにとってプライベートなものとみなされる。
PrefixはDNSのサブドメインに関わる(2023-01-20:理解できていない)。
`kubernetes.io/` と `k8s.io/` はK8sが予約語としているので使えない。

* ラベルの制限として以下がある
  * must be 63 characters or less (can be empty),
  * unless empty, must begin and end with an alphanumeric character ([a-z0-9A-Z]),
  * could contain dashes (-), underscores (_), dots (.), and alphanumerics between.

#### #### Label selectors 

ラベルセレクターによってユーザーはオブジェクトをSetとして扱うことができる。ラベルセレクターはK8sにとってコアなグルーピング機能である。

ラベルセレクターには以下の2つのタイプがある。

* equality-based (`=`, `!=` の演算子, `==`も使えて`=`と全く同じ意味)
* set-based (`in`,`notin` の演算子。 キー名だけを指定する"exists")

```
environment in (production, qa)
tier notin (frontend, backend)
partition      # exists
!partition     # Not exists
```

__【注意】equality-basedとset-basedの両方とも、カンマ区切りでの複数指定の場合、常にAND(&&)条件であり、OR(||)条件になることは無い。__

ラベルセレクターを空で指定したり指定しなかった場合の挙動はContextによって異なる。APIのタイプごとのドキュメントに記載があるので確認しておくこと。

#### #### API

##### ##### LIST and WATCH filtering

```
kubectl get pods -l environment=production,tier=frontend              # equality-basedでの検索 
kubectl get pods -l 'environment in (production),tier in (frontend)'  # set-basedでの検索 
kubectl get pods -l 'environment in (production, qa)'                 # set-basedではこのようにOR条件で検索可能
kubectl get pods -l 'environment,environment notin (frontend)'        # existsとnotinの合わせ技
```

##### ##### Set references in API objects

[services](https://kubernetes.io/docs/concepts/services-networking/service/) と [replicationcontrollers](https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller/) はPodのリソースをLabel Selectorで指定する。__このとき、ラベル指定はequality-basedのみがサポートされている。__

一方で、より最近登場した, Job, Deployment, ReplicaSet, DaemonSet, のオブジェクトらは、set-based の検索もサポートしている。以下のように指定できる。

```
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```

上述の条件において`matchLabels`と`matchExpressions`はAND条件で結ばれる。

また、ラベルは特定条件のPodを特定のノードにデプロイさせるようにする[ノード選定](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)にも利用される。

### ### [Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)

* ネームスペース対象オブジェクト → (e.g. Deployments, Services, etc)
* ネームスペース対象外(cluster-wide) オブジェクト → (e.g. StorageClass, Nodes, PersistentVolumes, etc)

> Note: 本番環境クラスターでは、`default`ネームスペースを使わないようにしてください。その代わり別のネームスペースを作成しそれを利用するようにしましょう。(My Note: 理由が書いてない。おそらくdefaultネームスペースはK8sが作るリソースも存在して問題になる可能性があるからだと思われる)

#### #### Initial namespaces

K8sが初めから提供するネームスペースが以下の4つ

* `default`
  * デフォルトネームスペース
* `kube-node-lease`
  * このネームスペースは各ノードにひもづく`Lease`オブジェクトを持つ。ノードLeaseによってkubeletがハートビートをコントロールプレーンへ送る。それによりノードの異常を検知できる。
* `kube-public`
  * クラスター全体で情報を読めるように持っている慣習的な？ネームスペース、とのこと。My Note:用途の意味が理解できてない(2023/01/26)
* `kube-system`
  * K8sシステムが作成したオブジェクトが存在するネームスペース

#### #### Working with Namespaces

> Note: `kube-`から始まるネームスペースはK8sの持ち物オブジェクトと被る可能性があるので避けましょう。

以下のように設定することでkubectlをする際の`--namespace XXX`を固定できる。

```
kubectl config set-context --current --namespace=<insert-namespace-name-here>
# Validate it
kubectl config view --minify | grep namespace:
```

#### #### Namespaces and DNS

Serviceが作られるとき、対応するDNS entryが作成される。 このときのドメインのフォームが `<service-name>.<namespace-name>.svc.cluster.local` になる。

そのため、ネームスペース名はDNS名称の規格であるRFC 1123 Label Namesにしたがうことが望ましい。

#### #### Not all objects are in a namespace

K8sにはネームスペース外のオブジェクトも存在する。どのオブジェクトがネームスペース外か内かを確認するコマンドが以下になる。

```
# In a namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false
```

#### #### Automatic labelling

__FEATURE STATE: Kubernetes 1.22 [stable]__

コントロールプレーンがすべてのネームスペースに対して`kubernetes.io/metadata.name`というイミュータブルなラベルを貼り付ける機能が出た。ただし、NamespaceDefaultLabelName [Feature Gate](https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/)がenanbledになっている場合である。

### ### [Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)

K8sのアノテーションの機能により、Non-identifyingなメタデータをオブジェクトにアタッチすることができる。__ツールやライブラリがアノテーションのメタデータを取得することが主な目的である__。

```json
"metadata": {
  "annotations": {
    "key1" : "value1",
    "key2" : "value2"
  }
}
```

> Note: アノテーションはKeyもValueもStringのみでBooleanやNumericなどを指定することはできない。

アノテーションの __用途例__ が以下である。

* オートスケーリングシステムによる見分けに利用するフィールド設定
* アプリケーションのビルド時におけるリリースIDやコミット/DockerImageハッシュなどを付与する
* モニタリングシステムに飛ぶURL
* クライアントライブラリやツールが利用するバージョンを埋め込むメタデータ
* リソースが存在している由来となっているツールのURL
* configやcheckpointsなどの軽量なロールアウトツール用のメタデータ(2023年1月30日時点で不明)
* 情報をどこで確認できるかを示すためのもの。例えばチームのウェブサイト、責任者の電話番号や、ページャー番号やディレクトリエンティティなど。
* システムのふるまいの変更や、標準ではない機能を利用可能にするために、エンドユーザーがシステムに対して指定する値(2023年1月30日時点で不明)

### ### [Field Selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/field-selectors/)

フィールドセレクタはリソースフィルタである。以下のような指定ができる。

* metadata.name=my-service
* metadata.namespace!=default
* status.phase=Pending

```
kubectl get pods --field-selector status.phase=Running
```

#### #### Chained selectors

以下のように検索条件をカンマ区切りにしてAnd条件で検索ができる。

```
kubectl get pods --field-selector=status.phase!=Running,spec.restartPolicy=Always
```

#### #### Multiple resource types 

以下のように複数のリソースをカンマ区切りで指定している場合でかつ、`--all-namespaces`と指定しても`metadata.namespace!=default`の条件で検索できる。

```
kubectl get statefulsets,services --all-namespaces --field-selector metadata.namespace!=default
```

### ### [Finalizers](https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/)(難。再勉強必要)

Finalizersはあるオブジェクト削除時のPre-Hookとして対象オブジェクト削除を指定条件を満たすまで削除させない状態にする機能。

オブジェクトの削除命令がK8s APIに来たとき、K8sは削除命令が来た時刻で`.metadata.deletionTimestamp`を設定する。

Finalizers(デフォルト実装があったりコーディングでカスタムしたりできるっぽい)での削除時用処理によって`metadata.finalizers`が削除されたことをK8sが検知した後に、対象オブジェクトは削除される。

デフォルト実装でよく使われるFinalizerが`kubernetes.io/pv-protection`である。pvはPermanent Volumeの略である。

#### #### Owner references, labels, and finalizers

[owner reference](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)の概念においても、finalizersが関係してくる。削除対象のオブジェクトがOwnerであり子がいる場合は、それも削除しようとし子が削除できない状況の場合はOwnerである対象オブジェクトを削除できない場合がある。

> Note: Finalizers起因で削除ができないとき、手動でFinalizersを削除する操作は控えましょう。(FinalizersはK8sが内部で削除するもの)。Finalizersが設定されている理由を突き止め、依存しているオブジェクトを手動で削除するなど別の方法を検討しましょう。

### ### [Owners and Dependents](https://kubernetes.io/docs/concepts/overview/working-with-objects/owners-dependents/)

いくつかのオブジェクトは他のオブジェクトのオーナーである。例えば、ReplicaSetはPodの集合のOwnerである。

オーナーシップの概念はラベルとセレクターとは異なる。例として、EndpointSliceオブジェクトを作成するServiceにおいて、ラベルにプラスしてEndpointSliceはowner referenceを持っている。Owner referenceは無関係のオブジェクトが干渉しないようにすることを助ける。

#### #### Owner references in object specifications

Dependant側のオブジェクトが`metadata.ownerReferences`データを持ちこれはオーナー側のオブジェクトを参照している。Dependant側のオブジェクトは`ownerReferences.blockOwnerDeletion`のBooleanなデータを持っており、K8sのガベージコレクションがオーナー側のオブジェクトを削除できるかを制御できる。

> Note: __ネームスペースを跨いだowner referenceは設計上許されていません__。

#### #### Ownership and finalizers

[foreground or orphan cascading deletion](https://kubernetes.io/docs/concepts/architecture/garbage-collection/#cascading-deletion)を利用すると、K8sはfinalizerをオーナーオブジェクトに追加する。foreground deletionでは、foreground finalizerを付与し、オーナー側を削除する前にコントローラーはDependant側のリソースを削除する。このときDependant側は`ownerReferences.blockOwnerDeletion=true`になっている。orphan deletion policyを設定している場合は、K8sはorphan finalizerを付与し、それによってコントローラーはオーナーオブジェクトを削除した後もDependant側のリソースを無視して削除をしない。

### ### [Recommended Labels](https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/)

アプリケーションを実際に運用する際に設定しておくことでツールが参照し機能に利用できる、推奨されるラベルが以下である。

```yaml
# This is an excerpt
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    app.kubernetes.io/name: mysql
    app.kubernetes.io/instance: mysql-abcxzy
    app.kubernetes.io/version: "5.7.21"
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: wordpress
    app.kubernetes.io/managed-by: helm
```