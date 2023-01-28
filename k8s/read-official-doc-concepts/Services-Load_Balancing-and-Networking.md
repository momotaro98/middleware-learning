
# # [Services, Load Balancing, and Networking](https://kubernetes.io/docs/concepts/services-networking/)

Kubernetesのネットワーキングは4つの懸念事項に対処します。

* Pod内のコンテナは、ネットワーキングを利用してループバック経由の通信を行います。
* クラスターネットワーキングは、異なるPod間の通信を提供します。
* Serviceリソースは、Pod内で動作しているアプリケーションへクラスターの外部から到達可能なように露出を許可します。
* Serviceを利用して、クラスタ内部のみで使用するServiceの公開も可能です。

## ## [Service](https://kubernetes.io/docs/concepts/services-networking/service/)

Serviceは"Podの集合"の上に乗っているアプリケーションを外部へ公開させるネットワークサービスとしての抽象的な方法である。K8sはPodごとにIPアドレスを与え"Podの集合"に1つのDNS名を与える。これによってServiceはロードバランスの機能も持たせることができる。

### ### Defining a Service

以下のServiceを作成したとする。

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  selector:
    app.kubernetes.io/name: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

このServiceは"my-service"という名前になり、`the app.kubernetes.io/name=MyApp`のラベルが付いた"任意のPod"に対して9376ポートで振り分ける。
This specification creates a new Service object named "my-service", which targets TCP port 9376 on any Pod with the app.kubernetes.io/name=MyApp label.

K8sはこのServiceに対してIPアドレスを割り当てる(cluster IPと呼ばれる)。このIPアドレスはServiceプロキシによって利用される。(詳細は以下の"Virtual IP addressing mechanism")に記載。

> Note: `targetPort`が省略された場合は`port`の値になる。

以下のように`targetPort`に対してPod側の`ports`に記載した命名を指定させることができる。

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    app.kubernetes.io/name: proxy
spec:
  containers:
  - name: nginx
    image: nginx:stable
    ports:
      - containerPort: 80
        name: http-web-svc

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app.kubernetes.io/name: proxy
  ports:
  - name: name-of-service-port
    protocol: TCP
    port: 80
    targetPort: http-web-svc
```

#### #### Services without selectors

ここから

#### #### EndpointSlices

#### #### Endpoints

#### #### Application protocol


## ## [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)

## ## [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)