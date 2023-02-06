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

#### #### Default image pull policy 

ここから