## [Images](https://kubernetes.io/docs/concepts/containers/images/)

### ### Updating images

`IfNotPresent`がデフォルトのPulling Policyである。このポリシーでは既にImageが存在しているときkubeletはImageをPullすることをスキップする。

#### #### Image pull policy

kubeletが使う`imagePullPolicy`のリストは以下。

* `IfNotPresent`
  * ローカルに存在しないときだけPullをする
* `Always`
  * kubeletは常にレジストリに対してクエリをかけて __Image [digest](https://docs.docker.com/engine/reference/commandline/pull/#pull-an-image-by-digest-immutable-identifier)__ を確認する。digestの値がローカルと一致している場合はImage自体のPullはせずキャッシュを利用するが、digestが異なっていれば、Pullをしてコンテナを立ち上げる。
* `Never`
  * kubeletは決してPullをしない。(なぜか)Imageがローカルに存在しているときはコンテナを立ち上げ、そうでなければFailになる。詳細は以下の"Pre-pulled images"を参照すること。

Imageの提供元(DockerHubなど)のキャッシングセマンティクスにより、`imagePullPolicy: Always`がより効率的になることができる。

> Note: `:latest`のタグを本番環境のコンテナに利用することは避けた方が良い。なぜなら稼働しているコンテナのバージョンが終えなくなりロールバックを適切に実行できなくなるリスクがあるためである。代わりに`v1.42.0`のような意味のあるタグを利用すること。

Imageのタグ利用では、タグが同じでもコードが異なった2つがMixされてデプロイされるリスクがある。それを無くすためには、`<image-name>:<tag>` ではなく、 `<image-name>@<digest>` に置き換えると良い。 (for example, `image@sha256:45b23dee08af5e43a7fea6c4cf9c25ccf269ee113168c19722f87876677c5cb2`)。

##### ##### Default image pull policy 

* `imagePullPolicy`を省いて
  * イメージタグが`:latest`ならばimagePullPolicyは`Always`になる
  * イメージタグも省いた場合もimagePullPolicyは`Always`になる
  * `:latest`以外のタグがついていれば、imagePullPolicyは`IfNotPresent`になる

> Note: imagePullPolicyはオブジェクト(Deploymentと思って良い)が"作成時"のみに設定されImageの更新時は変更がない。
> つまり例えば、Deploymentを初めて作成した際に`:v1.2.0`というタグが付いており、imagePullPolicyが`IfNotPresent`になった後に、タグを`:latest`に変更して再度Deploymentの更新をかけたとしても、imagePullPolicyは`IfNotPresent`のままである。作成後にimagePullPolicyを変更したければ手動で設定をする必要がある。

##### ##### Required image pull

常に強制的にImageのPullをしたい場合は以下のいずれかを設定すること

* imagePullPolicyを`Always`にする
* imagePullPolicyを省き かつ (イメージタグも省く or `:latest`タグにする)
* [AlwaysPullImages admission controller](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#alwayspullimages)を利用する

#### #### ImagePullBackOff

`ImagePullBackOff`によってPodが"Waiting"のステータスになることがある。Imageを取得できないときにImagePullBackOffになる。理由としてImage名が存在しなかったり`imagePullSecret`無しでPrivateレポジトリのイメージを取得しようとしたなどがある。"BackOff"というのはback-off delayをしながらK8sがImageをPullしようとするのを継続していることを意味する。back-off delayをしながらPullを継続するのは5分間であり、それ以上立つとエラーになる。

### ###【理解に自信無い(2023年2月7日時点)】 Multi-architecture images with image indexes

amdとかarmとかコンピュータアーキテクチャの差異を隠せるような仕組み、(の話のようだ)。[Image Index](https://github.com/opencontainers/image-spec/blob/main/image-index.md)というOCIの規格に沿ってレジストリに登録されていれば、K8s(kubelet)がこの規格の通りでPullしてくれるということ、っぽい。

ただ、この規格以前のための後方互換性(backward compatibility)のために、`pause`というイメージ名ならば`pause-amd64`というものも用意してあげる必要がある、ということっぽい。

### ### Using a private registry 

プライベートレジストリからPullするにあたってCredentialsを設定する方法はいくつかある。以下がそれである

1. プライベートレジストリへの認証するノードを設定する
2. プライベートレジストリ用のクレデンシャルを動的にfetchするKubeletクレデンシャルプロバイダー
3. Pre-pulled images
4. ImagePullSecretsをPodに指定する(__推奨アプローチ__)
5. Vendor指定またはローカル拡張

#### #### 1. プライベートレジストリへの認証するノードを設定する

(My Note)ノード設定の話ではなく、なぜかレジストリ側の設定をしている。意味が不明なのでSkip。

#### #### 2. プライベートレジストリ用のクレデンシャルを動的にfetchするKubeletクレデンシャルプロバイダー

> Note: このアプローチはkubeletが動的にレジストリのクレデンシャルをfetchする必要があるときに有効である。多くの一般的なのは、クラウドサービスが提供しているレジストリでその認証トークンの寿命が短いケースである。

この方法では kubelet に対してPluginバイナリを適用する設定をkubeletにする必要がある。

See [Configure a kubelet image credential provider](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-credential-provider/) for more details.

#### #### `config.json` の解釈

DockerとKubernetesでは設定ファイル(config.json)でのプライベートレジストリ認証設定である`auths`で仕様が異なる。Dockerではレジストリのroot URLは完全一致が条件であるが、Kubernetesではワイルドカード的に指定ができる。

```json
{
    "auths": {
        "*my-registry.io/images": {
            "auth": "…"
        }
    }
}
```

#### #### 3. Pre-pulled images

ノードに対して認証情報を予め設定しておくやり方である。

> Note: このアプローチはあなたがノード設定ができる権限があれば有効である。逆にクラウドプロバイダーがノードを扱っており勝手にノードをreplaceするような場合は不向きである。

#### #### 4. ImagePullSecretsをPodに指定する

> Note: このアプローチはプライベートレポジトリを使う場合の推奨アプローチである。

KubernetesはPod上のコンテナイメージレジストリキーを指定することをサポートする。`imagePullSecrets`は必ず同じネームスペース上に存在する必要がある。参照するSecretは必ず`kubernetes.io/dockercfg` or `kubernetes.io/dockerconfigjson`になる必要がある。

```
kubectl create secret docker-registry <name> \
  --docker-server=DOCKER_REGISTRY_SERVER \
  --docker-username=DOCKER_USER \
  --docker-password=DOCKER_PASSWORD \
  --docker-email=DOCKER_EMAIL
```

> Note: Podは自身のネームスペース上のSecretしか参照できない。そのためネームスペースごとに処理される必要がある。

以下が例である。

```
cat <<EOF > pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: foo
  namespace: awesomeapps
spec:
  containers:
    - name: foo
      image: janedoe/awesomeapp:v1
  imagePullSecrets:
    - name: myregistrykey
EOF

cat <<EOF >> ./kustomization.yaml
resources:
- pod.yaml
EOF
```

しかし、上述の`imagePullSecrets`設定は[ServiceAccountリソース](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)上で設定することでPodごとに指定しなくても良くなる。

Check [Add ImagePullSecrets to a Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#add-imagepullsecrets-to-a-service-account) for detailed instructions。

### ### Use cases

プライベートレポジトリがinternalなものでinternal内でアクセス制限されているならばそれで良い、という感じのことが書いてある。

## ## [Container Environment](https://kubernetes.io/docs/concepts/containers/container-environment/)

### ### Container environment

K8sはimageとvolumesのコンビネーションで実現するfilesystemを環境としてコンテナへ提供する。

#### #### Container information

コンテナの _hostname_ はPodの名前になる。それは`hostname`コマンドで取得できる。

Pod名とネームスペース名はコンテナ上の環境変数としてK8sが提供する[Downward API](https://kubernetes.io/docs/concepts/workloads/pods/downward-api/)を通して得られる。

#### #### Cluster information

Serviceの情報もコンテナの環境変数として得られる。

`foo`という名前のServiceが存在するとき、コンテナ上の環境変数として以下が定義された状態でコンテナは立ち上がる。

```
FOO_SERVICE_HOST=<the host the service is running on>
FOO_SERVICE_PORT=<the port the service is running on>
```

## [Runtime Class](https://kubernetes.io/docs/concepts/containers/runtime-class/)

## [Container Lifecycle Hooks](https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/)