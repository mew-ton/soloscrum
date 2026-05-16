---
title: /refine
description: 自由形式のアイデアを GitHub Issue に整形します。事前に janitor sweep を走らせ、closing PR がすでに merge 済みの open Issue を閉じます。
sidebar:
  order: 1
---

`/refine` は、ふわっとしたアイデア — 1 文のメモ、段落単位の文章、書きかけのバグ報告 — を、Background / Goal / Acceptance Criteria / Out of Scope の 4 セクションを持つ GitHub Issue に整形します。後続の command はこの形を前提に動きます。Issue を作る前に、まずバックログを sweep して、closing PR が merge 済みなのに open のまま残っている Issue を閉じます。

## 使い方

```bash
/refine <idea or feature description> [--no-janitor]
```

引数は自由なテキストです。`--no-janitor` を付けるとバックログ sweep をスキップします。GitHub API の挙動が不安定なとき、または command 冒頭の出力を静かにしたいときに使ってください。

## 処理の流れ

1. **バックログ janitor。** `/refine` は open Issue を 2 つの検出経路で走査します。**親 Issue（Sub-issue を持つもの）**については、すべての Sub-issue が close 済みなら親を close します。各 Subtask PR は `Closes #` で親を参照しない契約（[branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の parent-close セクションを参照）なので、janitor が親の唯一の close 経路です。**スタンドアロン Issue（Sub-issue なし）**については、closing keyword (`Closes #N` / `Fixes #N` / `Resolves #N` など) を持つ PR が merge 済みなら close します — GH の auto-close が発火しなかった場合の safety net です。出力の 1 行目は `Closed N stale Issue(s): #X, #Y` か `No stale Issues found`、`--no-janitor` 指定時は `Janitor skipped` です。janitor は close するのみで、reopen することはありません。
2. **アイデアの構造化。** PO agent がアイデアを読み、4 セクション構成の Issue 本文を組み立て、[priority](/ja/policies/priority/) ラベルを選び、size-check [SP](/ja/policies/story-points/) を算出します。
3. **サイズゲート。** size-check SP が 5 を超える、または計画される `/breakdown` で Subtask が 5 個を超えそうな場合、`/refine` はこれを *mis-scope の臭い*（複数 intent を束ねている可能性が高い）と判定し、Issue を作成する前に「複数の Issue への分割」を提案します。これは `/breakdown` の配信スライス（1 つの一貫した intent の PR がレビュー不能になるときに発火）とは別物です。[issue size](/ja/policies/issue-size/) を参照してください。
4. **承認。** 整形した Issue 本文をユーザに提示します。
5. **Issue 作成。** 承認後、priority ラベルを付けた状態で GitHub Issue を作成します。

## 典型的な流れ

`/refine "users should be able to reset their password by email"` を実行すると、最初の行に janitor の結果が出ます。掃除済みのリポジトリでは通常 `No stale Issues found` です。続いて PO agent が、ユーザニーズを説明する Background 段落、1 文の Goal、3-5 個の AC チェックボックス、明示的な Out of Scope を組み合わせた Issue 本文を提示します。priority (ユーザが初日から触る機能なら `high` など) と size-check SP も提示します。

SP が 5 以下なら承認して Issue を作成します。authentication / email infrastructure / form UI が実際には別々の feature（それぞれ独自の user-facing done を持つ）として混ざっていて SP が 8 になるような場合、command は「複数 intent を束ねている」と判定し、機能軸で分割するよう提案します — 各 piece に対して `/refine` を再実行します。一方、変更が 1 つの一貫した intent（例: *"password reset"*）だが配信が 1 つの reviewable PR に収まらない場合は、ここではサイズゲートを通過し、次のステップで `/breakdown` が配信を Subtask に切ります。

新規 Issue を起票しないセッションでも、`/refine` を最初に走らせるのは自然です。janitor sweep がバックログを正確に保ってくれます。

## 出力

- 1 行目: janitor の結果
- 作成した GitHub Issue の URL
- 適用された priority ラベル
- size-check SP (情報用。tracker には保存されません — tracker に保存される SP は `/breakdown` が書き込む subtask 側の値です)

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — `/refine` は PO agent が担当します
- [Issue フォーマット](/ja/policies/issue-format/) — `/refine` が生成する本文の形
- [Issue サイズ](/ja/policies/issue-size/) — `suggest_split` を発火させる閾値
- ライフサイクル上の次のステップ: [`/breakdown`](/ja/commands/breakdown/)
- canonical な契約: [`commands/refine.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/refine.md)
