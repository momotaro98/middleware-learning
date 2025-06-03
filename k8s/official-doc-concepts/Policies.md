# # [Policies](https://kubernetes.io/docs/concepts/policy/)

ポリシーとは？

K8sのポリシーは設定やランタイムの振る舞いを制御する設定のこと

## ## Apply Policies using API objects

いくつかのAPIオブジェクトがポリシーとして振る舞う(note:ポリシーは抽象的なものと言える)

以下のその例

* [NetworkPolicies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
  * can be used to restrict ingress and egress traffic for a workload.
* [LimitRanges](https://kubernetes.io/docs/concepts/policy/limit-range/)
  * manage resource allocation constraints across different object kinds.
* [ResourceQuotas](https://kubernetes.io/docs/concepts/policy/resource-quotas/)
  * limit resource consumption for a namespace.


....