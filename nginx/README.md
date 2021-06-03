
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

つづき