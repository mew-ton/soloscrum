---
title: Issue サイズ
description: Issue サイズの閾値 (max SP 5、max 5 subtask、日数は粗い校正シグナル) と suggest_split アクション。
sidebar:
  order: 4
---

SP > 5、または `/breakdown` の結果が 5 個を超える subtask になる場合、その Issue は大きすぎる。いずれかの閾値に引っかかると `/refine` か `/breakdown` が `suggest_split` を呼び、分割の仕方をユーザが決めることになる。

## 閾値

| メトリック | 閾値 | 意味 |
|---|---|---|
| SP | > 5 | 見積もりが SP スケールの最上段を超える |
| Subtask 数 | > 5 | breakdown が 5 個を超える subtask を生む |
| 見積もり日数 | > 2 日 | 粗い校正シグナルにすぎず、これ単独では分割を強制しない |

いずれかの閾値に当たると、`suggest_split` が機能軸 / レイヤー軸 / フェーズ軸で分割案を提示する。各分割が閾値の中に収まるかを確認したうえで、新しい Issue を作る前にユーザの承認を求める。

## いつ適用されるか

- `/refine` は、Issue を最初に書くタイミングで、PO の size-check SP を使って size gate を確認する。
- `/breakdown` は subtask を提案するときに gate を再確認する — breakdown が 5 個の subtask を超えるなら split test がもう一度発火する。

## なぜ日数は校正シグナルにとどまるのか

`max_sp: 5` は [`story-points`](/ja/policies/story-points/) で定義した scope × uncertainty の SP スケール上で機能する。したがって split test が問うているのは、「この Issue は複合せずに 1 つの PR の scope と決定セットに収まるか」だ。単一の PR が複数のサブシステムにまたがり、**かつ** 未解決の設計決定を複数抱えなければならない場合、その Issue は大きすぎる — モデルがどれほど速く下書きできるかとは関係なく、だ。

`max_estimated_days` は `/refine` 中の粗い校正チェックとして残してある: ざっくりした wall-clock 感覚が solo-dev のサイクルタイム (ユーザレビューを含む) で 2 日を明らかに超えるなら、scope / uncertainty の見積もりがおそらく低すぎる、というシグナルだ。これは主基準ではない。

## 例外

大規模リファクタリングや技術的負債の削減はこの閾値の対象外で、ユーザ判断に委ねる。

## 関連項目

- SP スケールそのもの: [`story-points`](/ja/policies/story-points/)。
- 正本の契約: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md)。
