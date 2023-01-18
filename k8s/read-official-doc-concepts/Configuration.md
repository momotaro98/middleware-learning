
## ## [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

### ### Types of Secret

* Opaque secrets
* Service account token Secrets
* Docker config Secrets
* Basic authentication Secret
* SSH authentication secrets
* TLS secrets
* Bootstrap token Secrets

#### #### Opaque secrets

`Opaque` は Secret 設定ファイルにてタイプが記述されていないときに設定されるデフォルトのSecretタイプである。kubectlで作成するとき、`generic`サブコマンドを使うときそれは`Opaque`にある。例で以下を実行するとOpaqueである空のSecretタイプが作成される。

```
kubectl create secret generic empty-secret
kubectl get secret empty-secret
```

```
NAME           TYPE     DATA   AGE
empty-secret   Opaque   0      2m6s
```

上記の`DATA`カラムは対象のSecretが持っているデータアイテムの数を表している。0は対象Secretが空であることを意味する。

