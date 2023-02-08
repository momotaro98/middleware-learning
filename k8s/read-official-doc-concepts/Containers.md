## [Containers](https://kubernetes.io/docs/concepts/containers/)

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

プライベートレポジトリからPullするにあたってCredentialsを設定する方法はいくつかある。以下がそれである

ここから