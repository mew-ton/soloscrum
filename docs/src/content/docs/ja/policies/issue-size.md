---
title: Issue サイズ
description: Issue サイズの閾値 (max SP 5、max 5 subtask、日数は粗いキャリブレーション信号) と `suggest_split` の動作を説明します。
sidebar:
  order: 4
---

Issue は SP が 5 を超えたとき、または `/breakdown` で 5 個を超える subtask が出るときに「大きすぎる」と判定します。いずれかの閾値を超えた時点で `suggest_split` が走り、どう切り分けるかを決めます。

## 閾値

| 指標 | 閾値 | 意味 |
|---|---|---|
| SP | > 5 | SP スケールの最大行を超えている |
| Subtask 数 | > 5 | `/breakdown` の結果が 5 個を超える |
| 推定日数 | > 2 days | キャリブレーション信号のみ — これだけでは分割を強制しない |

閾値を超えたとき、`suggest_split` が分割提案を提示します (機能軸 / レイヤ軸 / フェーズ軸など)。各分割案が閾値を満たすかを確認し、承認を得てから新規 Issue を作成します。

## 適用される場面

- `/refine` で Issue を新規作成するとき、PO が付けた size-check SP を使ってサイズチェックを行います
- `/breakdown` で subtask を提案するときにも再度チェックします。subtask 数が 5 個を超えるなら、また分割テストが走ります

## days がキャリブレーション扱いの理由

`max_sp: 5` は [`story-points`](/ja/policies/story-points/) で定義した scope × uncertainty スケール上で動きます。分割テストが問うているのは「この Issue は単一の PR スコープと判断セットに収まるか、それとも積み重なって肥大化するか」です。1 つの PR が複数のサブシステムを跨ぎ、しかも複数の未解決の設計判断を抱えるなら、モデルがどれだけ速く draft を書けるかとは無関係に大きすぎます。

`max_estimated_days` は `/refine` 時の粗いキャリブレーション項目です。wall-clock の感覚として、solo-dev サイクル (ユーザの review 込み) で 2 日を明らかに超えそうな場合、scope/uncertainty の見積もりが甘い可能性が高い、というシグナルです。主たる判定基準ではありません。

## 例外

大規模なリファクタリングや技術的負債の解消はこの閾値の対象外です。ユーザの判断に委ねます。

## 参考

- SP スケール: [`story-points`](/ja/policies/story-points/)
- canonical な契約: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md)
