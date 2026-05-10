---
title: define-issue-size
description: spec サマリ — Issue サイズの閾値 (max SP 5、max 5 subtask; 日数は粗い校正シグナルのみ) と suggest_split アクション。
sidebar:
  order: 7
---

`soloscrum-define-issue-size` は size gate です。タスクは無限に分解可能であるため、フレームワークは「この Issue は単一ユニットとしてライフサイクルに入るには大きすぎる」という具体的なバーが必要です。それが存在する理由です。

## 何をするか

閾値と、いずれかが超過されたときに発火するアクションを固定します:

| メトリック | 閾値 | 意味 |
|---|---|---|
| SP | > 5 | 見積もりが SP スケールの最大行を超える |
| Subtask 数 | > 5 | breakdown が 5 個より多い subtask を生成する |
| 見積もり日数 | > 2 日 | 粗い校正シグナルのみ — それ自体では split を強制しない |

いずれかの閾値が超過されると、`/refine` は `suggest_split` をトリガーします: 分割提案を提示し (機能軸、レイヤー軸、フェーズ軸で)、各分割が閾値内に収まることを確認し、新しい Issue を作る前にユーザの承認を得ます。

## いつ消費されるか

- `soloscrum-create-issue` (`/refine`) は、PO の size-check SP を使って Issue 作成時に size gate をチェックします。
- `soloscrum-split-into-tasks` (`/breakdown`) は、subtask を提案するときに gate を再チェックします — breakdown が 5 個の subtask を超えると、split test が再度発火します。

## 主要な入力と出力

入力は候補の Issue とその size-check SP / subtask 数です。出力は OK か、具体的な分割提案を伴う `suggest_split` アクションです。

## なぜ日数は校正のみなのか

`max_sp: 5` は [`story-points`](/policies/story-points/) で定義される scope × uncertainty SP スケール上で動作します。したがって split test は「この Issue は複合せずに 1 つの PR の scope と決定セットに収まるか?」というものです。単一の PR が複数のサブシステムにまたがり、**かつ** 複数の未解決設計決定を抱えなければならないとき、Issue は予算超過です — モデルがどれほど速くドラフトできるかに関わらず。

`max_estimated_days` は `/refine` 中の粗い校正チェックとして保持されます: rough な wall-clock 感覚が solo-dev のサイクルタイム (ユーザレビュー含む) で 2 日を明らかに超えるなら、それは scope/uncertainty 見積もりがおそらく低すぎるシグナルです。これが主基準ではありません。

## 例外

大規模リファクタリングと技術的負債削減はこれらの閾値の対象外です; ユーザの判断に委ねます。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md)。
- SP スケール自体については [`story-points`](/policies/story-points/) を参照。
