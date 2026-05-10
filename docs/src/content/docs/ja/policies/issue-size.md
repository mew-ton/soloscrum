---
title: Issue サイズ
description: Issue サイズの閾値 (max SP 5、max 5 subtask; 日数は粗い校正シグナルのみ) と suggest_split アクション。
sidebar:
  order: 4
---

Issue は SP > 5 のとき、もしくは `/breakdown` が 5 個より多い subtask を生成するとき、大きすぎます。いずれかの閾値が trip すると `/refine` か `/breakdown` が `suggest_split` を呼び、あなたが分割の仕方を決めます。

## 閾値

| メトリック | 閾値 | 意味 |
|---|---|---|
| SP | > 5 | 見積もりが SP スケールの最大行を超える |
| Subtask 数 | > 5 | breakdown が 5 個より多い subtask を生成する |
| 見積もり日数 | > 2 日 | 粗い校正シグナルのみ — それ自体では split を強制しない |

いずれかの閾値が超過されると、`suggest_split` が分割提案を提示し (機能軸、レイヤー軸、フェーズ軸で)、各分割が閾値内に収まることを確認し、新しい Issue を作る前にあなたの承認を得ます。

## いつ使われるか

- `/refine` は、Issue が最初に書かれるとき、PO の size-check SP を使って size gate をチェックします。
- `/breakdown` は、subtask を提案するときに gate を再チェックします — breakdown が 5 個の subtask を超えると、split test が再度発火します。

## なぜ日数は校正のみなのか

`max_sp: 5` は [`story-points`](/ja/policies/story-points/) で定義される scope × uncertainty SP スケール上で動作します。したがって split test は「この Issue は複合せずに 1 つの PR の scope と決定セットに収まるか?」というものです。単一の PR が複数のサブシステムにまたがり、**かつ** 複数の未解決設計決定を抱えなければならないとき、Issue は大きすぎる — モデルがどれほど速くドラフトできるかに関わらず。

`max_estimated_days` は `/refine` 中の粗い校正チェックとして保持されます: rough な wall-clock 感覚が solo-dev のサイクルタイム (ユーザレビュー含む) で 2 日を明らかに超えるなら、それは scope/uncertainty 見積もりがおそらく低すぎるシグナルです。これが主基準ではありません。

## 例外

大規模リファクタリングと技術的負債削減はこれらの閾値の対象外です; ユーザの判断に委ねます。

## 関連項目

- SP スケール自体: [`story-points`](/ja/policies/story-points/)。
- 正本の契約: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md)。
