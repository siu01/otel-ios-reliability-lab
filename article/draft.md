---
title: "永続化したら欠損0、でもSpanが3倍になった：OpenTelemetry Swiftの二重リトライを壊して測る"
emoji: "🧪"
type: "tech"
topics: ["opentelemetry", "swift", "ios", "observability"]
published: false
---

> 検証継続中のドラフトです。結論には必ずexperiment ID、生データ、
> reconciliation結果を対応させています。

## きっかけ

サーバーなら、送信に失敗したテレメトリをプロセスのメモリへしばらく
置いておける。しかしiOSアプリは圏外になり、バックグラウンドへ移り、
ユーザーに終了される。

では、OpenTelemetry SDKで`span.end()`を呼んだ100件のSpanは、実際には
何件バックエンドへ届くのだろうか。

今回の8秒障害では、永続化なしは0件、公式Defaultは100件、公式Instantは
200件届いた。さらに条件を分解すると、100件しか生成していないのに300件
届くrunまで再現した。

欠損を0にすることと、重複を0にすることは別問題だった。

## 先に見つかった意外なもの

独自のディスクキューを作るつもりで調査を始めたが、
`opentelemetry-swift` 2.5.0には既に
`PersistenceSpanExporterDecorator`が存在した。

さらに「永続化あり」は一種類ではない。

- `default` / `lowRuntimeImpact`: 非同期ディスク書き込み。
- `instantDataDelivery`: 同期ディスク書き込み。

同じPersistence Exporterでも、突然の終了に対する生存率と実行コストが
違う可能性がある。そこで、独自実装より先に公式実装を壊して測ることにした。

## 推測ではなくsequence IDを突合する

各Spanへ以下を付与する。

- `lab.experiment.id`
- `lab.run.id`
- `lab.sequence`
- `lab.transport`
- `lab.persistence`
- `lab.ended_at_unix_nano`

アプリ側の`generated.jsonl`とCollector側の`received-otlp.jsonl`を専用CLIで
突合し、欠損・重複・別runの混入を分離する。

## E000：正常系が壊れていないことを確認する

| Persistence | Generated | Received | Duplicate | Missing |
|---|---:|---:|---:|---:|
| なし | 100 | 100 | 0 | 0 |
| Default | 100 | 100 | 0 | 0 |
| Instant | 100 | 100 | 0 | 0 |

正常接続＋明示的flushでは、3条件とも100件が一意に到達した。
これは障害耐性の証明ではなく、以後の比較が壊れた測定器によるものではないと
確認するための対照実験である。

## E001：Collectorを8秒後に起動する

アプリを毎回クリーンインストールし、Collectorが存在しない状態で100 Spanを
生成する。アプリ起動が戻ってから8秒後にCollectorを起動し、その後30秒間、
アプリへ追加操作をしない。

| Persistence | Generated | Unique received | Total received | Duplicate | Missing |
|---|---:|---:|---:|---:|---:|
| なし | 100 | 0 | 0 | 0 | 100 |
| Default | 100 | 100 | 100 | 0 | 0 |
| Instant | 100 | 100 | 200 | 100 | 0 |

永続化なしは、Collector復帰後も自動再送されなかった。Defaultは100件すべてを
一度ずつ回収した。ところがInstantは欠損0と引き換えに、全sequenceを2回ずつ
送った。

偶然を疑い、Instantだけ新しいrun IDとクリーンインストールで追試した。
結果は再び`total received=200`、1〜100がすべて2回だった。

## 最初の推理：forceFlushとworkerが競合した？

アプリは100 Span生成後に`TracerProvider.forceFlush()`を呼んでいた。公式
Persistence Exporterにも定期workerがある。この2経路が同じファイルを読んだ
のではないか、と考えた。

そこでE002では、run metadataへ`flushMode`を追加し、明示的flushだけを無効化
した。他の条件はInstant、8秒障害、100件、30秒窓のままである。

結果は重複0ではなく、さらに増えて300件だった。

| Experiment | Explicit flush | Total received | Exact multiplicity |
|---|---|---:|---:|
| E001 Instant | あり | 200 | 2x |
| E001 Instant追試 | あり | 200 | 2x |
| E002 Instant | なし | 300 | 3x |

明示的flushは必要条件ではなかった。

## ソースを読む：retryの所有者が2つある

固定した`opentelemetry-swift` 2.5.0のソースを追うと、失敗した同じ論理batchを
2層が保持していた。

1. `PersistenceExporterDecorator`は、送信失敗なら永続ファイルを削除しない。
2. `OtlpHttpTraceExporter`も、失敗した送信配列を`pendingSpans`へ戻す。

次の永続化retryで同じ100件が再びHTTP exporterへ渡ると、HTTP側のpending
100件と合流して200件になる。それも失敗すればpendingは200件になり、次の
ファイルretryで300件になり得る。

```mermaid
flowchart LR
  A["永続ファイル 100"] --> B["HTTP pending 0"]
  B --> C["request 100: failure"]
  C --> D["永続ファイル 100 + pending 100"]
  D --> E["request 200: failure"]
  E --> F["永続ファイル 100 + pending 200"]
  F --> G["request 300: success"]
```

ただしソースからの推論だけでは足りない。実際のHTTP requestを観測する必要が
ある。

## E003：HTTP bodyが100→200→300へ増えるのを記録する

公式`BaseHTTPClient`を変更せずwrapし、request開始・完了時刻、body bytes、
timeout、成否を`http-attempts.jsonl`へ記録した。Collector停止時間を
4/6/8/10秒へ変え、コードは固定した。

| Collector停止 | 完了した失敗 | 成功body bytes | Total received | Multiplicity |
|---:|---:|---:|---:|---:|
| 4秒 | 0 | 27,818 | 100 | 1x |
| 6秒 | 1 | 55,418 | 200 | 2x |
| 8秒 | 2 | 83,018 | 300 | 3x |
| 10秒 | 2 | 83,018 | 300 | 3x |

![E003で完了したHTTP失敗回数と配送倍率を比較したグラフ](./assets/e003-retry-amplification.png)

8秒runのHTTP lifecycleは次の通りだった。

1. 27,818 bytes：接続拒否で失敗。
2. 55,418 bytes：接続拒否で失敗。
3. 83,018 bytes：成功。

bodyは失敗ごとに27,600 bytesずつ増え、最後のrequestをCollectorが300 Spanと
して受け取った。各sequenceだけでなく、対応するtrace IDとspan IDも3コピーで
同一だった。アプリが300 Spanを新規生成したのではなく、同じ`SpanData`を
再送した証拠になる。

今回の4 runでは、次がすべて成立した。

```text
配送倍率 = 成功までに完了したHTTP失敗回数 + 1
```

10秒runが4倍ではなく3倍なのも重要である。backoffにより、Collector復帰までに
完了した失敗が2回だったためだ。停止秒数ではなく、失敗して二重に保持された
回数が直接の倍率になっていた。

また、失敗は2秒timeoutではなく、数ミリ秒で完了した`NSURLErrorDomain -1004`
の接続拒否だった。「timeout後も古いURLSessionTaskが生き残っただけ」という
別の説明は、この行列には不要だった。

## E004：retryを永続化1層だけにすると100件へ戻った

原因が二重のretry stateなら、HTTP exporterから内部pendingを外せばよい。
そこで、受け取った`SpanData`をOTLP protobuf requestへ変換して送るが、失敗時に
内部保持しないlab用stateless exporterを作った。永続ファイルとretry timingは
引き続き公式Persistence Exporterが担当する。

10秒障害で、stateful/statelessの両方が成功前に2回の接続拒否を完了した。

| Persistence配下のexporter | HTTP body bytes | Total received | Duplicate | Missing |
|---|---|---:|---:|---:|
| 公式stateful | 27,818 → 55,418 → 83,018 | 300 | 200 | 0 |
| lab stateless | 27,818 → 27,818 → 27,818 | 100 | 0 | 0 |

8秒のstateless runも、1回失敗後に同じ27,818-byte bodyを再送し、100件を一度ずつ
回収した。retry stateを永続化1層へ限定することで、欠損0を維持したまま3倍を
1倍へ戻せた。

これは原因に対する介入結果であり、相関だけではない。一方、このlab exporterは
header、compression、metrics、shutdownなど公式実装の全機能を再実装したもの
ではない。設計原則のmechanism proofであって、そのままproduction投入できる
完成品とは主張しない。

## E005：アプリを終了しても100件を回収できるか

E004までは、Collector停止中もアプリのプロセス自体は生きていた。iOSで本当に
気になるのは、ディスクへ保存したあとに元のプロセスが消え、新しいプロセスが
同じSpanを見つけられるかである。

そこでCollectorを止めたまま100 Spanを生成し、ホストから永続ファイルを実際に
観測してSHA-256を記録してから、`simctl terminate`でアプリを終了した。その後に
Collectorを起動し、同じrun IDと永続化ディレクトリを指定してアプリを再起動した。
再起動側はtelemetryを構成するだけで、Spanを1件も新規生成しない。

| Persistence | 終了直前のファイル | 再起動後のHTTP | Total received | Duplicate | Missing |
|---|---:|---|---:|---:|---:|
| Instant | 1（107,770 B） | 27,818 B × 1成功 | 100 | 0 | 0 |
| Default | 1（107,756 B） | 27,818 B × 1成功 | 100 | 0 | 0 |

どちらも最初のプロセスではHTTP送信が始まっていない。再起動後のプロセスが
永続ファイルを読み、1回のrequestで100件を回収した。終了前後の
`generated.jsonl`と`run.json`は、それぞれSHA-256が完全一致した。再起動時に
別の100 Spanを作って帳尻を合わせたのではない。

これで「retryの所有者を永続化1層へ限定する」構成は、送信先の一時障害だけで
なく、完全に保存されたbatchに対する制御されたプロセス終了も越えられた。

ただし、ファイルを観測してから終了した点は意図的な境界条件である。非同期
書き込みの途中、jetsam、クラッシュ、端末再起動まで生存すると一般化はしない。

## 何が「不可能を可能」にしたのか

8秒障害で永続化なしの回収率は0%だった。公式Defaultは同じ条件で100%を一意に
回収した。つまり、アプリが生きている間の一時的な送信先障害は、設定だけで
0%から100%へ変えられた。

さらに、完全な永続ファイルを確認後にプロセスを終了しても、DefaultとInstantの
両方が新しいプロセスから100件を一意に回収できた。少なくともこの制御条件では、
「元のプロセスが死んだら終わり」でもなかった。

一方、InstantとstatefulなOTLP/HTTP exporterを重ねると、早いretryが欠損を
回収しながらコピーを増幅した。at-least-onceを2層へ独立に持たせると、各層が
正しくretryしても、組み合わせ全体が望むsemanticsになるとは限らない。

## 実運用で考えられる対策

E004とE005により「retryの所有者を1層にする」方針は、一時障害と制御された
プロセス再起動の両方で欠損0・重複0を両立した。ただしproduction向けの実装方式
と、他の対策とのコスト比較は未検証である。

- retryの所有者を1層にする（mechanism proof済み）。
- 永続化側がretryするなら、失敗batchを内部保持しないstateless exporterを使う。
- Collectorや保存先でtrace ID/span IDをキーにdeduplicateする。

下流dedupは可能そうだが、保持期間・状態量・コストをreceiver側へ移す。
次の実験では、非同期書き込みの途中で終了した場合と、stateless exporterの
protocol parityを比較する。

## 試行錯誤も証跡に残す

E001では2回の無効試行があった。1回目は手作業で8秒を超過し、2回目はアプリが
experiment IDを`E000`へhard-codeしていた。どちらも削除せず、なぜ結論へ
採用しなかったかをmanifestへ残した。

また、HTTP計測ファイル追加後の最初のbuildは、XcodeGen再生成漏れで失敗した。
これもlab notebookへ残している。成功runだけ並べると、測定器をどう疑い、
どの仮説を捨てたかが見えなくなるからだ。

## 制約

- iPhone 17 Simulator / iOS 26.4.1。
- `opentelemetry-swift` 2.5.0、core 2.5.1。
- `otelcol` 0.157.0。
- loopbackの接続拒否、OTLP/HTTP protobuf、100 Span。
- 各停止時間は1 run。ただし8秒3倍は非計測E002でも独立再現した。
- 再起動試験は`simctl terminate`による制御された終了であり、ファイル観測後に
  実行した。

SDK全バージョン、実端末、すべてのネットワーク障害へ一般化はしない。

## 次に壊すもの

- stateless exporterに公式実装相当のheader・compression・shutdownを足せるか。
- 非同期永続化の書き込み境界で終了すると何件残るか。
- jetsam・クラッシュ・端末再起動・アプリ更新でも回収できるか。
- 1,000 Span時の書き込み時間、ストレージ、メインスレッド影響。
- downstream dedupに必要な状態量。

## 結論

OpenTelemetry Swiftの公式Persistence Exporterは、8秒の送信先障害に対して
0件だったSpanを100件回収できた。しかしInstant presetと今回のOTLP/HTTP
exporterの組み合わせでは、失敗ごとに同じbatchを2層が保持し、成功requestが
100→200→300 Spanへ増幅した。HTTP側をstatelessにしてretryの所有者を
永続化1層へ絞ると、同じ2回失敗でも成功requestは100 Spanのままになった。
完全な永続ファイルを確認してプロセスを終了したE005でも、DefaultとInstantは
再起動後に100件を一度ずつ回収した。

「永続化をONにしたから安心」ではなく、誰がretryを所有し、失敗した同じ
telemetryを各層が何コピー保持するかまで測る必要がある。
