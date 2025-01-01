
# 書籍 GitHub

書籍: https://nextpublishing.jp/book/11389.html

GitHub: https://github.com/govargo/kubecontorller-book-sample-snippet

# How to create/delete K8s cluster with Kind

```
# 作成
kind create cluster --name cluster-for-customcontroller --config=kind.yaml

# 確認
kubectl cluster-info --context kind-cluster-for-customcontroller
kubectl config get-contexts
kubectl get nodes -o wide

# 削除
kind delete clusters cluster-for-customcontroller
```
