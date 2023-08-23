
# # [Use Port Forwarding to Access Applications in a Cluster](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

> This page shows how to use `kubectl port-forward`` to connect to a MongoDB server running in a Kubernetes cluster.
> This type of connection can be __useful for database debugging__.

## ## Forward a local port to a port on the Pod

__note: `kubectl port-forward`` はローカルとPodを直接つなげる。(ServiceのClusterIPを利用しない。)__

> `kubectl port-forward`` allows using resource name, such as a pod name, to select a matching pod to port forward to.

```
# Change mongo-75f59d57f4-4nd6q to the name of the Pod
kubectl port-forward mongo-75f59d57f4-4nd6q 28015:27017
```
which is the same as

```
kubectl port-forward pods/mongo-75f59d57f4-4nd6q 28015:27017
```
or
```
kubectl port-forward deployment/mongo 28015:27017
```
or
```
kubectl port-forward replicaset/mongo-75f59d57f4 28015:27017
```
or
```
kubectl port-forward service/mongo 28015:27017
```