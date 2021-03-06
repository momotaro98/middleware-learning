---
marp: true
---

# Chapter 9 一貫性と合意

トランザクションがアプリケーションに対してAID(ACIDのCが無い)を提供しシステムの問題を無いように振る舞う抽象化であるように、
8章での分散システムの問題(※)をアプリケーションにとって抽象化したものの概念の1つが**合意(consensus)**である。

> ※: すなわちパケットはロストし、順序は狂い、複製され、ネットワークでどれだけの遅延が生じるかわかりません。クロックはせいぜい大まかにしか正しくありません。ノードは(たとえばGCのため)いつクラッシュしたりするか分かりません。

-----

## 9.1 一貫性の保証

結果整合性(eventual consistency)は正しいデータ状態へと収束するので**収束性(convergence)**の方が適切な名前かもしれない。

結果整合性は**弱い**保証であり、レプリカが**いつ**収束するのかについては何も語らない。

弱い一貫性と強い一貫性の関係は、トランザクション分離レベルの強さに類似点がある。(強さを上げるとパフォーマンスに影響するところ)

ただし、それぞれ注目していることが独立している。トランザクション分離の主眼は、並行してトランザクションの実行することから生じるレース条件を避けることにあるのに対し、分散の一貫性が主眼とするのは遅延やフォールトに際してレプリカの状態を調整することにある。

強い一貫性の代表が**線形化可能性**である。

-----

## 9.2 線形化可能性

レプリケーションが複数台あるときに一度どこかのレプリケーションから最新が返されたらそれ以降はどのレプリケーションもその最新よりも古い値を返さない保証が、**線形化可能性(linearizability)**である。
→ **最新性の保証(recency guarantee)**

線形化可能性は、原子的一貫性、強い一貫性、即時一貫性、外部一貫性、と呼ばれることもある。

-----

TODO: 図9-4

それぞれの四角い棒はクライアントが発行したリクエストであり、棒の開始点はリクエストが送信された時刻、そして棒の終末点はクライアントがレスポンスを受信した時点である。

-----

### 9.2.2 線形化可能性が必要なケース (書籍では"線形化可能性への依存")

* レプリケーションのLeader選出
  * 単一Leaderのレプリケーション選出には本当にLeaderが1つしかないことを保証する必要がある。
  * Lockを使うことになる。Lockの実装がなんであれ、線形化可能性である必要がある。
  * 分散LockやLeader選出の実装にはZooKeeperやetcdのような協調サービス(合意アルゴリズム)が利用される。
* ユニーク性制約の保証
  * RDBMSでの2つの重複データのどちらかが書き込み時にエラーになるデータユニーク制約は線形化可能性が求められる。
  * この状況はLockに似ている。
* クロスチャンネルタイミング依存関係
  * ファイルストレージとキュー、などの独立した2つの通信チャネルを利用するようなシステムでは順序の逆転があってはいけない場合があり、線形化可能性を保証する必要がある。

-----

### 9.2.3 線形化可能性なシステムの実装

* シングルLeaderレプリケーション
  * → すべてが線形化可能なわけではない
* 合意アルゴリズム
  * → 線形化可能
* マルチLeaderレプリケーション
  * → 線形化可能ではない
* Leaderレスレプリケーション
  * → 線形化可能にはならないケースが存在する

-----
### CAP定理

以下のトレードオフがある。

* アプリケーションの線形化可能が**必須の**要件の場合、
  * ネットワーク障害がある際はレプリカを利用することは**できない**。
* アプリケーションの線形化可能が**必須ではない**要件の場合、
  * ネットワーク障害がある際はレプリカを利用することが**できる**。

-----

#### [役に立たないCAP定理]

> CAPは、Consistency、Availability、Partition toleranceの3つの中から2つを選択することとされます。しかしこれは誤解を招きます。ネットワークの分断はフォールトの一種なので、選択に関係するようなものではなく、好むと好まざるとに関わらず生じるものです。
> ネットワークが正常に動作しているなら、システムは一貫性(線形化可能性)と完全な可用性をどちらも提供できます。ネットワークにフォールトが生じると、線形化可能性と完全な可用性のどちらかを選択しなければなりません。したがって、CAPを表現するなら**ネットワーク分断が生じた時に一貫性と可用性のどちらかを選ぶのか**、という方が良いでしょう。
> CAPには歴史的に大きな影響力があったものの、システムの設計における実際的な価値はほとんどないのです。

-----

#### 9.2.4.2 線形化可能性とネットワークの遅延

マルチコアCPUのRAMをはじめ、多くの分散データベースでも線形化可能性を切り捨てている理由はパフォーマンスであり、耐障害性ではない。線形化可能性を提供すれば速度は落ちる。

> もっと効率的な線形化可能なストレージの実装は無いのでしょうか？その答えは「無い」だと思われます。AttiyaとWelchは、線形化可能性が求めるのであれば、読み書きのリクエストに対するレスポンスタイムは、少なくともネットワークの遅延の不確実性に比例することを証明しました。
> 線形化可能性を持つ高速なアルゴリズムは存在しませんが、もっと弱い一貫性モデルははるかに高速化できるので、レイテンシに敏感なシステムにおいてこのトレードオフは重要なのです。

-----

## 9.3 順序の保証

### 9.3.1 順序と因果関係

順序づけは**因果関係**を保つことに役に立つ。**因果律**はイベント間に順序関係を発生させる。

> システムが因果律から導かれる順序付けに従うのであれば、そのシステムは**因果律において一貫している(causally consistent)**と言えます。

-----

#### 9.3.1.1 因果律に基づく順序と全順序の違い

全順序 集合 A (a, b, c) と 集合 B (b, c) には全順序の関係がある。
半順序 集合 C (a, b, c) と 集合 D (d, e, f) には半順序の関係がある。

* 線形化可能性
  * 操作は全順序
* 因果律
  * 半順序。並行に行われているなら比較不能ということ。
-----

#### 9.3.1.2 線形化可能性は因果律の一貫性よりも強い

> 線形化可能性は因果律一貫性を**暗に含む**ということです。すなわち、線形化可能性を持つシステムは、因果律を正しく保持します。

線形化可能性を本当に必要とするシステムは少なく、多くの場合本当に必要なのは因果律における一貫性である。

因果律における一貫性を追求することは、未来のシステムに期待できる方向性である。

#### 9.3.1.3 因果律の一貫性における依存関係の捕捉

どのように因果律の一貫性を実装するか。

5章の図5-13での読み取り時にどのバージョンのデータであるかを読み取り書き込み時にDBにそのバージョンを知らせる、という方針。

バージョン読み取りをより汎化させたものがバージョンベクトルである。

------

### 9.3.2 シーケンス番号の順序

シーケンス番号を持つことでシングルLeaderレプリケーションのシステムは書き込みの全順序を規定し、これは因果律との一貫性を持つ。

#### 9.3.2.1 因果的ではなないシーケンス番号生成器

単一のLeaderが存在しない(Multi-Leaderの)場合は各ノードの操作に対するシーケンス番号は**因果律の一貫性を持たない**。

#### 9.3.2.2 ランポートタイムスタンプ

上記のMulti-Leaderの課題に対応する方法としてランポートタイムスタンプがある。

ランポートタイムスタンプによって全順序をもたせることができる。

#### 9.3.2.3 タイムスタンプの順序づけでは不十分

上記のようなランポートタイムスタンプを使うことで因果律の一貫性を持つ操作の全順序を定義するが、分散システムにおける一般的な多くの問題を解決するには十分ではない。

ユニーク制約をMulti-Leaderで対応するにはタイムスタンプでは**即座に**成功を判断することができない。

------

### 9.3.3 全順序ブロードキャスト (実装手法)

**全順序ブロードキャスト**(total order broadcast) あるいは**アトミックブロードキャスト**(atomic broadcast)の要件。

* 信頼できる配信
  * メッセージがロストすることはあってはならない。
* 全順序づけされた配信
  * メッセージはすべてのノードに同じ順序で配信されなければならない。

#### 9.3.3.1 全順序ブロードキャストの利用

全順序ブロードキャストは

* ZooKeeperやetcdのような合意サービスで実際に実装されている。
* まさにデータベースのレプリケーション(単一Leader)で必要とされるもの。
* 直列化可能なトランザクションの実装にも使われる。

全順序ブロードキャストはメッセージが配信された時点で順序が確定することが重要。

-----

#### 9.3.3.2 & 9.3.3.3 (理解合っているか自信無い)

全順序ブロードキャスト実装したログで書き込みの線形化可能なレジスタが作れ、合意アルゴリズムを加えることで読み取りの線形化可能性なレジスタになる。

線形化可能なレジスタがあれば全順序ブロードキャストを実装できるが、このとき必要な線形化可能なシーケンス番号生成器である線形化可能なレジスタを耐障害性の観点で作成するには合意アルゴリズムが必要になる。

------

## 9.4 分散トランザクションと合意

### 9.4.3 耐障害性をもつ合意

提案(propose)と決定(decide)

* 一様同意 (uniform agreement)
  * 2つのノードが異なる決定をしていないこと
* 整合性 (integrity)
  * 2回決定をしているノードがないこと
* 妥当性 (validity)
  * ノードが値vを決定したら、vを提案しているノードがあること
* 終了性 (termination)
  * クラッシュしていないすべてのノードは、最終的に何らかの値を決定すること

-----

#### 9.4.3.1 合意アルゴリズムと全順序ブロードキャスト

> 耐障害性を持つ合意アルゴリズムで最も広く知られているのは、VSR, Paxos, Raft, Zabです。

(Multi-Leaderにおいて)ノード郡が次に送信したいメッセージを提案しするという"合意回"を複数回すことが全順序ブロードキャストにあたる。

#### 9.4.3.2 シングルリーダーレプリケーションと合意

シングルLeaderならばデフォルトで全順序ブロードキャストであるが、"リーダー選出"において合意が必要になる。

このとき、Leaderがユニークであることを保証する必要がある。

-----

#### 9.4.3.3 エポック番号とクオラム

リーダーがユニークであることを保証するためにエポック(epoch)番号を定義し、各エポック内でリーダーがユニークであることを保証する。 (Paxosではballot番号、Raftではterm番号と呼ぶ)

リーダー選出に対してインクリメントされるエポック番号が与えられ、2つのエポックにおいて2つの異なるLeaderが衝突したら、大きいエポック番号を持つLeaderが優先される。

**クオラム(Quoramu)**を使って投票される。投票には2回のラウンドがあり、1回目はリーダー選出のため、そして2回目がLeaderの提案に対する投票。
これ投票プロセスは表面上は2相コミット(2PC)に似ているが、大きな違いは2PCではコーディネータは選出されないことと、投票では全ノードが返答する必要があるのに対して、Quoramu数以上ならばOKになる点。

-----

#### 9.4.3.4 合意の限界

合意アルゴリズムのデメリットが以下。

* 投票プロセスは、一種の同期レプリケーションであり、パフォーマンスに問題がある。
* 2つの障害に耐えるためには最低5ノードが必要など規模が大きくなる
* 多くの合意アルゴリズムは参加ノードが固定である前提でありクラスタへのノード追加や削除が単純に行えない。
  * **動的なメンバーシップ**の拡張を加える必要があるが、それほど理解が進んでいない。

概して合意アルゴリズムは、障害が発生しているノードの検出をタイムアウトに依存しており、一時的なネットワークの問題のために、頻繁に投票を行うことで全体のパフォーマンスが悪くなる(このときエラー自体で安全性の性質を損なうことはない)。

------

### 9.4.4 メンバーシップと協調サービス

> **ZooKeeper**のモデルは、GoogleのLockサービスでありChubbyを参考にしており、実装されているのは全順序ブロードキャスト(合意)だけではなく、特に分散システムを構築する上で有益であることが分かっている他の興味深い機能群が実装されています。

* 線形化可能でアトミックな操作
  * Lockの実装。成功するのは1つだけであることを保証する。
* 操作の全順序
  * プロセスの一時停止時の問題のために**フェンシングトークン**が必要になる。
  * フェンシングトークンはLockが取得されるたびに単調にインクリメントされる。
* 障害検出
  * ハートビートが消えた場合ZooKeeperはセッションが死んだと宣言する。
  * エフェメラル(ephemeral)ノードというノードが処理をする。
* 変更通知
  * 通知をサブスクライブすることでクライアントは他のクライアントの変更を監視することができる。

  #### 9.4.4.3 メンバーシップ

ZooKeeperなどは**メンバーシップサービス**に関する研究の長い歴史の一部とみなせる。

メンバーシップサービスは、アクティブでクラスタのメンバーとなっているノードを判断する。

合意と障害検出を組み合わせれば、どのノードが生きていてどのノードが落ちたかをノード間で合意できる。
