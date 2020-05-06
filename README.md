## 何に困っていて何をテストしたいか
raspberry piからoracle dbに繋ぐプログラムを書きたい。
そのためには、oracle dbに繋ぐためのodbc driverが必要になる（各言語はdriverを用いて、oracle dbとやりとりをするため）。

しかし、raspiのcpuアーキテクチャはamd等ではなくarmで、oracle用のodbc driverがarm用に用意されていない。
具体的には、以下のoracle isntant clientがoracle用のodbc driverで、これがarm用には用意されていない。
https://www.oracle.com/database/technologies/instant-client/downloads.html

そこで、dockerでarm対応のimageを元にして、oracle用のodbc driverを入れて動く状態にして、
それをarm用のimageとしてbuildして、raspiで動かせばもしかして動く・・・？
（odbc入れるタイミングでは、arm用にbuildしてるわけじゃないし、普通に厳しい気はする）
と思い、とりあえず試してみることに。

**結論としてはダメだった**。
コンテナの起動はできるけど、sqlplusを使うことはできなかった。

## 試し方
```bash
# on local mac
docker buildx build -t xxxx/xxxx --platform linux/arm/v7 --push .

# on raspi
docker pull xxxx/xxxx
docker run -it xxxx/xxxx /bin/bash
sqlplus # error
```

## 代替手法

oracle instant clientを入れる方法（sqlplusを利用できるようにする方法）は上記のように、通常の手法だと厳しい。

ただし以下の「4.) Running a fat Client on the Raspberry Pi」をみると、x86-platformをエミュレートできるExaGear Desktopなどを入れることで、sqlplus等をいれて動かせたとのこと。
https://blog.dbi-services.com/running-the-oracle-client-on-a-raspberry-pi/

またsqlclなどの軽量なクライアントは、普通にraspi上でも動くとのこと。

さらにjavaを用いる場合は、jdbc（java実装のodbc driver）があり、javaが動くプラットフォームならoracle dbに繋げると思われる。raspi上でもjavaは動くので、java用いてる場合、raspiからでもおそらく問題なくoracleに繋げる。他の言語の場合は（正確にはjvmで動く言語ではない場合は）、oracle instant clientなどのodbc driverが必要になり、raspi上でその言語から直接oracle dbに繋ぐことができない（該当言語からsqlclなどを呼び出して用いれば別だと思うが）。
https://armadillo.atmark-techno.com/forum/armadillo/1404
https://www.oracle.com/technetwork/jp/content/0127-1330-db-middleware-297515-ja.pdf

## 参考情報

### raspiへのdockerの入れ方
以下の「Install using the convenience script」で入れられる。
https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script

上記ドキュメントにも書いてあるが、apt-getで入れる方法（「Install using the repository」の方法）はraspiでまだサポートされていないとのこと。

docker入れても数百メガ程度しか、raspiの容量は消費されない。
上記で入れれば、以下をraspiで実行できるようになるはず。
```bash
docker run hello-world
```

以下をしておかないと、sudoつけないと実行できないかも
```bash
sudo usermod -aG docker pi
```


### raspi用のdocker imageのbuild
以下の後半に記載あり。
https://qiita.com/koduki/items/0ed303dac5d32646194f

こんな感じでarm向けのimageをbuildできる。
```bash
docker buildx build -t xxxx/xxxx --platform linux/arm/v7 --push .
```

### linuxへのoracle instant clientの入れ方
以下の「6.2.2.1 zipファイルからのOracle Instant Clientのインストール」などに、x64-12向けのインストール方法が書いてある。
https://docs.oracle.com/cd/E90713_01/OREAD/installing-oracle-database-instant-client.htm


### oracle dbのmacへの入れ方
mac用のバイナリがないため、dockerを用いて入れる方法を使う。

以下のqiitaと、
https://qiita.com/yuttoku/items/f9aa9c3caf17d95c81b7

以下の公式ドキュメントが参考になる。
https://github.com/oracle/docker-images/tree/master/OracleDatabase/SingleInstance

上記の方法で実行すれば1521ポートで繋げるようになる。


