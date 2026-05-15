---
title: Issue size
description: Issue と Subtask の分割基準は intent の coherence で判断します（作業量ではない）。SP > 5・subtask 数 > 5 は mis-scope の臭い。`/breakdown` は単一 PR でレビュー不能なときに発火します。
sidebar:
  order: 4
---

soloscrum の分割基準は **intent の coherence** で判断します。作業量そのものではありません。下の数値しきい値は「**この Issue は複数 intent を束ねている可能性が高い**」という signal であって、単一 intent に許される作業量の hard limit ではありません。

大きいが一貫している単一 intent は分割しません。配信を `/breakdown` で複数の reviewable PR（Subtask）にスライスします。

## しきい値

| Metric | Threshold | 何を意味するか |
|---|---|---|
| SP | > 5 | (scope × uncertainty) の見積もりがこのレベルになっているなら、Issue は複数の「why + done」を抱えている可能性が高い。AC を読み直し、「何を満たせば完了か」の答えが複数あって、しかも統一的な intent を共有していないかを点検します |
| Subtask count | > 5 | 1 つの intent を配信するのに reviewable PR が 5 本以上要るなら、それは「mistakenly 複数 intent を組み合わせた」可能性が高い。mis-scope の臭い — `/refine` に戻して整理します |
| Estimated days | > 2 | 粗いキャリブレーションのみ。それ単独で分割を強制しません |

「**複数 intent が束ねられている**」の答えが no（1 つの一貫した intent がたまたま大きい）なら、Issue はそのままにします。作業は `/breakdown` で Subtask（配信スライス）に切り、Issue 分割はしません。

**エッジケース。** 再評価しても単一の一貫した intent と確認できる一方で、配信に reviewable Subtask が 6 個以上必要なケース（大規模なマイグレーション、広範なリファクタリングなど）があります。まずもう一度スライシングを見直し、関連スライスをまとめて 5 個以下に収められないかを検討します。再パスでも 6 個以上必要なら、下の「リファクタリング例外」と同様に扱い、user 判断に委ねます（状況を明示して指示を仰ぐ）。

## `/breakdown` のトリガ

`/breakdown` は、1 つの Issue の intent を単一 PR で配信したらレビュー不能になるとき、Subtask を生成します。配信・レビュー可能性の問いであって、scope の問いではありません。

- 1 つの PR でレビューできる → `/breakdown` 不要、そのまま `/develop` へ（`CLAUDE.md` も *"Issues that fit within a single develop unit can skip this step"* と書いており、canonical の [`soloscrum-define-branch-commit`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の branch-per-Issue モードがこれにあたります）
- 1 つの PR にすると unreviewable → `/breakdown` が Subtask を生成します。各 Subtask は配信のスライスであって intent のスライスではありません — [`issue-format`](/ja/policies/issue-format/) の Subtask 本文セクションを参照

## 分割の軸（Issue 単位）

「複数 intent が束ねられている」と診断したとき、次のいずれかの軸で分割を提案します。

- **Feature 軸** — MVP vs 拡張、または独立したユーザー向け能力。それぞれが自分の intent（自分の why、自分の done）を持ちます
- **Phase 軸** — その phase が独立した「done」を持つ場合のみ（例: 自分の SLO を独立に検証できる performance hardening）。自分の done を持たない phase は intent ではなく配信作業 — `/breakdown` の範疇であって、Issue 分割の軸ではありません

歴史的な **layer 軸**（backend / frontend）は Issue 分割の軸では**ありません**。1 機能の backend と frontend は同じ intent と同じ done を共有していて、layer で割ると断片の AC（*"user can reset password"*）が単独では成り立たなくなります。layer 軸の分割は Issue 分割ではなく `/breakdown` の Subtask スライスとして有効です。

## days がキャリブレーションのみである理由

`max_sp: 5` は [`story-points`](/ja/policies/story-points/) で定義される scope × uncertainty のスケールで動作します。しきい値の主要なドライバは uncertainty 軸（複数 subsystem にまたがる未解決判断の数）で、これは「実は複数 intent では？」と高い相関があります。作業量そのものは Issue 分割の駆動要因にはなりません。

`max_estimated_days` は `/refine` 中の粗いキャリブレーション。solo-dev のサイクルタイム（user レビュー含む）2 日を明らかに超える感覚があるなら、scope / uncertainty の見積もりが低すぎる signal です。主たる基準ではありません。

## 例外

大規模リファクタリングや技術的負債の解消はしきい値の対象外。user 判断に委ねます。リファクタリングの intent は *"the codebase is in state X"* — ファイル数や PR 数によらず単一の一貫した intent です。

## 参考

- [`issue-format`](/ja/policies/issue-format/) — 分割基準が依拠する Issue-vs-Subtask discriminator
- [`story-points`](/ja/policies/story-points/) — SP スケール
- canonical な契約: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md)
