
## Labels, annotations and taints used on API objects

### [cluster-autoscaler.kubernetes.io/safe-to-evict](https://kubernetes.io/docs/reference/labels-annotations-taints/#cluster-autoscaler-kubernetes-io-safe-to-evict)

__Type: Annotation__

_Example: `cluster-autoscaler.kubernetes.io/safe-to-evict: "true"`_

__Pod で利用__

このAnnotationで"true"に設定されているとき、クラスターオートスケーラー(CA)はたとえ他のルールがあったとしてもEvictすることができる。CAはこのAnnotationに"false"が設定されているPodに対しては決してEvictすることはない。つまり、重要なRunningのままにしたいPodには"true"を設定できる。もしこのAnnotationが設定されていない場合はCAはPodレベルの振る舞いに従う。
