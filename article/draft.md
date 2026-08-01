---
title: "iPhoneを圏外・強制終了にしたらSpanは何％消える？ OpenTelemetry Swiftを壊して確かめる"
emoji: "🧪"
type: "tech"
topics: ["opentelemetry", "swift", "ios", "observability"]
published: false
---

> This draft contains placeholders. A statement graduates into a conclusion only
> after its experiment ID, raw evidence, and reconciliation artifact are linked.

## きっかけ

サーバーなら、送信に失敗したテレメトリをプロセスのメモリへしばらく
置いておける。しかしiOSアプリは圏外になり、バックグラウンドへ移り、
ユーザーに終了される。

では、OpenTelemetry SDKで`span.end()`を呼んだ100件のSpanは、実際には
何件バックエンドへ届くのだろうか。

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

## E001：Collectorを後から起動する

TODO: 永続化なし、Default、Instantを比較する。

## E002：Span生成後にアプリを終了する

TODO: 終了タイミングを段階化し、BatchSpanProcessor内とディスク書き込み後を
区別する。

## E003：再起動後に回収できるか

TODO: 欠損率、重複率、回収時間、残留ファイルを比較する。

## コスト

TODO: 1,000 Span時の生成時間、ストレージ増加量、メインスレッド停止、
アプリサイズ差を記録する。

## 結論

TODO: E001以降の結果が揃うまで書かない。

