
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