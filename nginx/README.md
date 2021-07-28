
## location ディレクティブ

以下 演算子

* `location /files/` (演算子なし) ← /files/で始まるすべてのパスが一致する。
* `location = /` ← `/` で完全一致のパスだけ一致する。
* `location ~ 正規表現パターン` ← 正規表現でパターン一致。
* `location ^~ 正規表現パターン` ← 正規表現よりも優先順位が上がる前方一致。
* `location @名前` ← コンテキストに名前をつける特別な書式になり、リダイレクト先にコンテキストを指定する場合に使われる。

### (演算子) 優先順位

1. `=`  完全一致
2. `^~` 優先順位が高い正規表現
3. `~`  優先順位が低い正規表現
4. 演算子なしの前方一致で最長のもの

### ネストしたlocationディレクティブ

__以下のような注意点がある__

```
location /upload/ {
  # アップロードされたファイル
}

location ~ \.php$ {
  # スクリプトを実行
  # /upload/ba.php のような場合もこちらが使用されてしまう
}
```

これを、前方一致を先に評価したい場合は、次のように書きます。

```
location /upload/ {
  # アップロードされたファイル
}

location / {
  # /upload/ 以下はマッチしない
  location ~ \.php$ {
    # スクリプトを実行
    # /upload/ba.php はマッチしない
  }
}
```

### rootとindexディレクティブ

rootディレクティブは、ドキュメントルートを指定する。

```
location / {
  root /www/dir;
  index index.html index.htm;
}
```

### aliasディレクティブ

以下の __root__ の場合は /files/a.html が示すファイルは /data/files/a.html となる。

```
location /files/ {
  root /data/;
}
```

以下の __alias__ の場合は /files/a.html が示すファイルは /data/a.html となる。

```
location /files/ {
  root /data/;
}
```

## URLの書き換え

> nginxは、URLの書き換えが発生すると、書き換え後の新たなURLを対象に、条件判定とURLの書き換えを再度行います。
> 書き換えは10回までで超えると500エラーが返ります。

### 判定

#### パス名での判定

```
location ~ ^/path1/(.+\.(?<ext>gif|jpe?g|png))$ {
  # /path1/test.gif
  # ↓
  # $1にtest.gif
  # $2と$extにgifが入る
}
```

#### map ディレクティブによる文字列マッチングの判定

```
map $http_user_agent $mobile {
  default           0;
  ~(Android|iPhone) 1;
}
server {
  if ($mobile) {
    # AndroidかiPhoneの場合
  }
}
```

### 書き換えの動作

#### return ディレクティブによるリダイレクト

```
return 301 http://www.example.com/;
return http://www.example.com/;
```

2つ目の省略の場合は302(Moved Temporarily)になる。

#### rewriteディレクティブによる書き換え

```
location /noflag {
  rewrite ~/noflag /a_noflag;
  rewrite ~/a_noflag /b_noflag;
}

location /a_noflag {
  rewrite ~/a_noflag /c_noflag;
}
```

上記の場合、アクセス先は`/b_noflag`になる。

```
location /noflag {
  rewrite ~/noflag /a_noflag last;
  rewrite ~/a_noflag /b_noflag last;
}

location /a_noflag {
  rewrite ~/a_noflag /c_noflag last;
}
```

上記のlastフラグがある場合、アクセス先は`/c_noflag`になる。

```
location /noflag {
  rewrite ~/noflag /a_noflag break;
  rewrite ~/a_noflag /b_noflag break;
}

location /a_noflag {
  rewrite ~/a_noflag /c_noflag break;
}
```

上記のbreakフラグがある場合、アクセス先は`/a_noflag`になる。

#### locationディレクティブの@プレフィックス

> あくまでもパス名とは無関係に、コンテキストを定義するための書式です。

```
location / {
  # ファイルが見つからなければWebアプリケーションへ
  try_files $uri $uri/ @fallback;
}
location @fallback {
  # Webアプリケーションに転送
  proxy_pass http://backend;
}
```

### 書き換え動作がわからなくなったときのロギング設定

> rewrite_logディレクティブでログを出力するように設定すると、nginxは、エラーログに書き換えに関する情報を、書き出すようになります。ログレベルは、noticeです。

```
server {
  rewrite_log on;
  error_log /var/log/nginx/rewrite.log notice;
}
```

# WordPressでやってみる

TODO Later

# 6章 TSL セキュリティ

TODO Later

# 7章 リバースプロキシ

### リバースプロキシの基本設定

#### upstreamコンテキストとseverコンテキストの設定

```
http {
  upstream app1 {
    server 192.168.1.10:8080;
    server 192.168.1.11:80;
    server 192.168.1.12:8080;
  }

  server {
    listen 80;
    location / {
      proxy_pass http://app1;
    }
  }
}
``` 

#### パス名を含んだproxy_pass

```
server {
  location /path {
    proxy_pass http://app1/next/;
    # /path が /next/ に変換される
    # /path1/test.gif へのアクセス → バックエンドの /next/1/test.gif に
  }
}
```

### バックエンドからの応答の書き換え

バックエンドのWebサーバが返すリダイレクトをキャッチして対応する必要がある。

#### proxy_redirect ディレクティブ

```
location /one/ {
  proxy_pass http://backend/two/;
  proxy_redirect http://backend/two/ http://example.com/one/; # default と同じ (つまりこのケースはわざわざproxy_redirectを書かなくて良い)
}

location /three/ {
  # URLの書き換え
  rewrite ^/three/1 /three/2;
  # http://example.com/three/file -> http://backend/four/2/file に変換
  proxy_pass http://backend/four/;
  # http://backend/four/2/redirect -> http://example.com/three/1/redirect に戻る
  # default だと http://example.com/three/2/redirect に
  proxy_redirect http://backend/four/2 http://example.com/three/1;
}
```

## キャッシュ処理とバッファ

> リバースプロキシのキャッシュ処理をうまく使うと、バックエンドの負荷を下げるとともに性能を向上させることができます。リバースプロキシのキャッシュは次のような設定をします。

```
http {
  proxy_cache_path /var/cache/nginx/rproxy
                  levels=1:2 keys_zone=proxy1:10m
                  inactive=1d;
  
  upstream backend {
    server 192.168.1.10;
  }

  server {
     ...
    location / {
      proxy_cache proxy1;
      proxy_pass http://backend;
    }
  }
}
```

#### proxy_cache_path ディレクティブ

> proxy_cache_pathは、httpコンテキストに記述するディレクティブで、第1引数がキャッシュに使うディレクトリです。

* keys_zone => ゾーン名とサイズを指定する。ゾーンとはnginxの複数のworkerで共有するメモリ領域のことで、ゾーンに名前を付けて区別することができる。
* levels    => キャッシュディレクトリの構造を示す。
* inactive  => キャッシュがアクセスされなくなってから捨てられるまでの時間を指定する。デフォルトは10分。

#### proxy_cache ディレクティブ

```
server {
   ...
  location / {
    proxy_cache proxy1;
    proxy_cache_bypass $http_authentication $http_cookie; # キャッシュからレスポンスを返さない用ディレクティブ
    proxy_no_cache $http_authentication $http_cookie;     # キャッシュに保存させない用ディレクティブ
    proxy_pass http://backend;
  }
}
```

### バッファ処理

> バッファは1つのリクエスト処理の中で使われます。
> バックエンドからのレスポンスが終わると、クライアントへの転送が終わっていなくても、バックエンドとの接続を切ってしまい、バッファに貯めておいた残りのデータをクライアントに送るという動作になります。
> これにより、バックエンド側がいつまでの接続されたままにならず、次のリクエストの処理ができるようになるのです。

```
server {
  location / {
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_max_temp_file_size 1024m;
    proxy_temp_file_write_size 8k;
    proxy_busy_buffers_size 8k;
  }
}
```

## リバースプロキシとHTTPS

タイプが2つある

1. リバースプロキシでSSL/TLSを終端させるもの
2. リバースプロキシではTCPの接続を中継するだけで、バックエンドまで暗号化された状態を保ってHTTPSへアクセスさせるもの

### HTTPSのリバースプロキシ (NginxでHTTPSを紐解くパターン)

```
upstream backend {
  server 192.168.1.10;
  server 192.168.1.11;
}

server {
  # HTTPSの設定
  listen 443 ssl;
  ssl_certificate /etc/pki/tls/certs/your-server crt;     # 証明書ファイルの場所
  ssl_certificate_key /etc/pki/tls/certs/your-server.key; # 秘密鍵の場所

  # 接続先バックエンドとURLパスの関連付け
  location / {
    proxy_pass http://backend;
  }
}
```

### TCPストリームのロードバランサ (NginxがHTTPSを紐解かずHTTPレイヤの中身を見ないパターン)

```
# nginx.conf
http {
  ...
}

# httpコンテキストの外に書く
stream {
  error_log /var/log/nginx/stream.log info;
  include /etc/nginx/stream.d/*.conf;
}
```

## WebSocketとリバースプロキシ

> WebSocketの双方向通信ではリクエスト/レスポンスの対応の仕組みをなくし、必要なときに双方向に通信ができる、生のソケットと同様の通信ができるようになります。
> WebSocketはHTTPやHTTPSと同様に80番や443番のポートを使いますが、「http://」や「https://」ではなく、「ws://」や「wss://」で始まるURLを使ってアクセスします。

> WebSocketも接続の最初はHTTPリクエストの形をしています。HTTPのUpgradeやSec-WebSocket-Protocolといったヘッダを使ってクライアントとサーバでネゴシエーションを行い、接続をWebSocketの接続に変更します。

### WebSocketへの対応

```
http {
  # $http_upgradeの中身が空かそうじゃないかで$connection_upgradeの中身が決まる
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  server {
    ...
    location /chat/ {
      proxy_pass http://backend;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;
    }
  }
}
```

> 上記の設定は、パス名が/chat/で始まるURLに対して、Upgradeヘッダが指定されていない場合はConnectionヘッダをcloseに設定し、それ以外はConnectionヘッダにupdradeを設定するという内容です。
> また、WebSocketはHTTP/1.1の規格ですが、nginxはバックエンドとの通信はデフォルトでHTTP/1.0が使われるため、proxy_http_versionでHTTP/1.1を使うように設定します。

# 8章 性能向上

### 性能情報のモニタリング

#### stub_statusの設定と出力

> nginxでは、接続中のクライアント数などの情報をHTTPで取得できる、stub_statusというモジュールがあります。このstub_statusの出力に対応したプラグインを、muninやcactiにインストールすると、定期的にアクセスして情報を蓄積し、グラフ化することもできます。

> stub_status が出力しているのは、サーバー内部の統計情報です。外部に公開する必要はないので、アクセス元を制限したり、アクセスログに混入させないようにすると良いでしょう。

```
server {
  location /status {
    stub_status;
    access_log off;  # アクセスログを残さない
    allow 127.0.0.1; # localhost からのアクセスのみを許可
    deny all;
  }
}
```

stub_statusの出力は次のようなものです。

```
Active connections: 291
server accepts handled requests
 16630948 16630948 3107465
Reading: 6 Writing: 179 Waiting: 106
```

* Active connections: 現在の接続数
* server accepts handled requests: nginxが起動してからの累積値
  * 最初の値は、これまで接続してきたクライアントの接続数を示します。
  * 次の値は、処理できた接続数を示します。
  * 最後の値はこれまでに処理したリクエスト数です。
* Reading: 現在ヘッダの受信街になっている接続数です。
* Writing: レスポンスの送信中になっている接続数です。
* Waiting: Keep-Aliveなどで接続を保った状態で、クライアントからのリクエストを待っている接続数です。

#### レスポンス時間のログ出力

`$request_time`という変数に秒単位で小数点以下3桁、ミリ秒の精度で設定されるため、log_formatディレクティブで`$request_time`を出力するようにします。

## キャッシュによる性能向上

### リクエストヘッダによるキャッシュ制御

リクエストヘッダに乗るやつ

* `If-Modified-Since`ヘッダ: 送信されるのは時刻情報で、Webサーバーはその時刻より後にコンテンツが更新されていなければデータ無しに「304 Not Modified」というレスポンスを返す。
* `If-None-Match`ヘッダ: 以前に送られたETagヘッダの内容を送信し、WebサーバーはETagの情報を基に、以前に送信したコンテンツから更新があるかどうかを判断する。

### レスポンスヘッダによるキャッシュ制御

#### キャッシュの制御

* `Cache-Control`ヘッダ: 引数にあるものが以下
  * no-store
  * no-cache
  * public
  * private
  * max-age

#### キャッシュの有効期限

キャッシュの有効期限を決めるのがExpiresヘッダ。Cache-Controlヘッダでmax-ageが指定されている場合、Expiresヘッダの内容は無視される。

#### コンテンツの更新

コンテンツが更新されたかどうかの判断材料にするヘッダとして、ETagヘッダやLast-Modifiedヘッダがある。

ETagヘッダには更新を判定できる文字列を返し、その文字列が次にクライアントから If-None-Matchヘッダとして渡される。

Last-ModifiedはリクエストでのIf-Modified-Sinceに対応する。

#### ヘッダの付与

通常、nginxでレスポンスヘッダを付けるには、add_headerディレクティブを使う。

ただし、add_headerディレクティブでCache-ControlやETag、Expiresヘッダを付けることもできますが、キャッシュ制御に関しては専用のexpiresディレクティブがあるのでそちらを使うと便利です。

#### 時刻情報の制御

ExpiresとCache-Controlヘッダは、expiresディレクティブを使って制御できます。


#### ファイルの更新時刻を起点とする設定

expiresディレクティブで時間情報の前に「modified」を引数に設定すると、時刻の計算の起点が現時刻ではなくファイルの更新時刻になり、これも定期的に更新されるコンテンツには便利です。

#### 例

```
server {
  location / {
    etag    off;
    expires off;
  }
  location /images/ {
    etag    on;
    expires 10d;
  }
}
```

ファイルタイプ(html or jpeg or pdf)によってExpiresの値を変更したい場合は、次のようにmapディレクティブと組み合わせると直感的に記述できます。

```
map $sent_http_content_type $expires {
  default         off;  # デフォルトはキャッシュしない
  application/pdf 10d;  # PDFファイルは10日間キャッシュする
  ~image/         max;  # 画像ファイルは目一杯キャッシュする
}

server {
  expires $expires;
}
```