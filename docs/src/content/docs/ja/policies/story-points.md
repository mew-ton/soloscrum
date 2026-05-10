---
title: define-story-points
description: spec サマリ — 2 段階の SP 構造 (Issue size-check、Subtask 登録) と scope × uncertainty SP スケール。
sidebar:
  order: 10
---

`soloscrum-define-story-points` は SP の定義です。SP は **scope × uncertainty に錨を下ろした size class** であり — 時間単位ではありません。

## 何をするか

次を固定します:

- 2 段階の SP 構造: Issue レベル SP (PO が `/refine` で行う entry-gate サイズチェック) と Subtask レベル SP (Dev が `/breakdown` 中に tracker に登録する値)。
- SP スケールと各行の意味。
- 稼働中の tracker profile ごとの値の登録方法 (`github-only` では GitHub Projects v2 `SP` Number フィールド; `linear+github` では Linear `estimate` フィールド)。

## 2 つの段階

**Issue SP** は粗さチェックです。PO は `/refine` 中に、Issue がライフサイクルに入れるほど小さいか、それとも先に [`define-issue-size`](/reference/define-issue-size/) が `suggest_split` を発火する必要があるかを判断するためにこれを使います。これはどこにも保存され **ません** — レコードではなく、決定への入力です。

**Subtask SP** が実際に記録される値です。Dev は `/breakdown` 中に subtask の AC からこれを計算し、`soloscrum-tracker-{github|linear}-set-sp` 経由で tracker に書き込みます。これが backlog planning と進捗追跡で使われる値です。

## SP スケール

| SP | Scope | Uncertainty | 校正 (観測値、単位ではない) |
|----|-------|-------------|---|
| 1  | 1 ファイル / 1 関心事 | すべての決定が既知 | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 ファイル / 単一スキル領域 | 1 つの軽微な決定 | ~100K-200K tokens, agent ~10-20 min |
| 3  | 単一サブシステム横断 | 1-2 個の設計決定 | ~200K-500K tokens, agent ~20-45 min |
| 5  | 複数サブシステム横断 | 複数の設計決定 | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (予算超過) | (予算超過) | 割り当てない — `define-issue-size` に従って split |

## なぜ scope × uncertainty で時間ではないのか

時間アンカーは意図的に単位ではありません。モデル速度はリリースごとに変化し (今日の「2 時間」は来月の「20 分」になる)、agent は並列で動くため wall-clock 比較が歪み、人間の時間と AI agent の時間は線形にマッピングされません。SP を時計単位に固定することはスケールを不安定にしました。校正カラムは sanity-check のために存在し、入力としてではありません。

## 見積もり手順

両段階で:

1. AC / Goal を読んで scope を特定する: いくつのサブシステム / 関心事に触れるか?
2. uncertainty を特定する: AC の後にいくつの未解決設計決定が残るか? 何か新規のものはあるか?
3. (scope, uncertainty) を SP 表にマッピングする。両軸が収まらなければならない; 迷ったら高い行を選ぶ。
4. 結果が 5 を超える場合、Issue は予算超過 — [`define-issue-size`](/reference/define-issue-size/) に従って split し再見積もりする。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-story-points/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-story-points/SKILL.md)。
- tracker profile ごとの SP 値の保存場所については、[tracker profile 概念](/concept/tracker-profile/) と [tracker operations リファレンス](/reference/tracker-operations/) を参照。
