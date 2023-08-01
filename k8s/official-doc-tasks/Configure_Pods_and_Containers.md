


## [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

[kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)は __liveness probe__ を使ってコンテナをRestartさせるべきタイミングを知ることができる。例えば、アプリケーションがデッドロックになっていることを liveness probe は検知でき、それによってコンテナは動いているが処理が進まないといった状況をRestartによって打破できる。

kubeletは __readiness probe__ を使ってコンテナがトラフィックを受け付ける準備ができているかを知ることができる。Pod内のすべてのコンテナがReadyのとき、そのPodはReadyとみなされる。readiness probeのシグナルはServiceのバックエンドとしてどのPodが使われているかをコントロールするために用いられる。PodがReadyではないとき、そのPodはServiceロードバランサの対象から外される。

kubeletは __startup probe__ をつかってコンテナアプリケーションがスタートしたことを知ることができる。 Startup Probe が設定されているとき、 liveness と readiness Probe は Startup Probe が成功するまでスタートしない。つまり、liveness, readiness probe はアプリケーションのスタートアップを邪魔しない。この挙動は、Slow Startなコンテナに対してliveness probeのチェックを使わせるのに用いられる。これにより、コンテナが立ち上がる前に liveness probe 起因でコンテナがkillされてしまうことを避けることができる。

> __Caution__ : Liveness probes can be a powerful way to recover from application failures, but they should be used with caution. Liveness probes must be configured carefully to ensure that they truly indicate unrecoverable application failure, for example a deadlock.  
>  
> __Note__ : Incorrect implementation of liveness probes can lead to cascading failures. This results in restarting of container under high load; failed client requests as your application became less scalable; and increased workload on remaining pods due to some failed pods. Understand the difference between readiness and liveness probes and when to apply them for your app.

[解説] → Liveness probe での失敗トリガーを緩くすると頻繁に再起動されてしまうのでトリガー設定には注意すること。パフォーマンス劣化の原因になるぞ。

### ### [Define a liveness command](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#define-a-liveness-command)

todo

### ### Define a liveness HTTP request 

todo

### ### Protect slow starting containers with startup probes

todo