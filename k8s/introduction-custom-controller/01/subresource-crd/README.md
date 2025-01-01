
```
# CRD作成
kubectl apply -f subresource-crd/sample-crd-scale-ga.yaml
# CRD確認
kubectl get crd
# CR作成
kubectl apply -f subresource-crd/example-cr-scale.yaml
# CRのreplicas数変更
kubectl scale sample/my-cr-sample-object --replicas 5
# CRのreplicas数確認
kubectl describe sample
```
