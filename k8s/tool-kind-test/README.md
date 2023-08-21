
How to use [kind](https://kind.sigs.k8s.io/)

ref: https://qiita.com/tomoyafujita/items/5a3c06705f62c5732bc5

```
kind create cluster --name multi-node --config=multi-node.yaml

k config get-contexts
k get nodes -o wide
k apply -f app-nginx.yaml

kind delete clusters multi-node
```
