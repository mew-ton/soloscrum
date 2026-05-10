---
title: /refine
description: 自由形式のアイデアを GitHub Issue に構造化する。事前に backlog janitor sweep を実行し、closing PR が既に merge された open Issue をクローズする。
sidebar:
  order: 1
---

`/refine` は入口です。アイデア — 1 文、1 段落、半分しか形になっていない bug report — を渡すと、soloscrum の他のすべての command が読み解く Background / Goal / Acceptance Criteria / Out of Scope の形に整った GitHub Issue が出てきます。その前に、closing PR が既に merge された stale-open な Issue を backlog から sweep します。

## Usage

```bash
/refine <idea or feature description> [--no-janitor]
```

引数は自由テキストです。`--no-janitor` を渡すと backlog sweep をスキップします — GitHub API が不安定なときや、command 開始時の出力をすっきりさせたいときに便利です。

## What happens

1. **Backlog janitor.** `/refine` は open Issue を走査し、それぞれについて closing keyword (`Closes #N`, `Fixes #N`, `Resolves #N` など) で参照していて既に merge 済みの PR を探します。そのような PR を持つ Issue は reason `completed` でクローズされます。出力の最初の行は `Closed N stale Issue(s): #X, #Y` か `No stale Issues found` (`--no-janitor` を渡したときは `Janitor skipped`) です。janitor はクローズしかしません — 再オープンは決してしません。
2. **Idea structuring.** PO agent がアイデアを読み、4 セクションの Issue 本文を抽出し、[priority](/policies/priority/) ラベルを選び、size-check [SP](/policies/story-points/) を計算します。
3. **Size gate.** size-check SP が 5 を超えている場合、`/refine` は Issue を oversized として flag し、作成前に分割を提案します。閾値については [issue size](/policies/issue-size/) を参照。
4. **Confirmation.** 構造化された Issue 本文がユーザに提示され、承認を求められます。
5. **Issue creation.** 承認後、priority ラベル付きで GitHub Issue が作成されます。

## Typical flow

典型的なセッションは *"users should be able to reset their password by email"* のようなアイデアから始まります。`/refine "users should be able to reset their password by email"` を実行します。出力の最初の行は janitor の結果 — クリーンな repo では普通 `No stale Issues found` です。次に PO agent が構造化された Issue 本文を提示します: ユーザのニーズを説明する Background 段落、1 文の Goal、3〜5 個の AC checkbox、その Issue が意図的にカバーしないものを列挙する明示的な Out of Scope。priority (初日からユーザが触れる feature なら `high`) と size-check SP も surface されます。

SP が 5 以下なら、ユーザが確認して Issue が作成されます。authentication / email infrastructure / password form UI にまたがる変更で SP が 8 として返ってきた場合、command は Issue が大きすぎることを伝え、feature 軸での分割を提案します — このときユーザは `/refine` を分割した各ピースで再実行するか、単一 Issue scope のままにする意味があるなら `/breakdown` で subtask に分けに進みます。

`/refine` は新しい Issue を追加していないときでも、任意のセッションを始める自然な場所です — janitor sweep が backlog を正確に保つので、次に取りかかるものが open に偽装された既出荷の作業ではないことが保証されます。

## Output

- 最初の行に janitor summary。
- 作成された GitHub Issue URL。
- 適用された priority ラベル。
- size-check SP (informational; 任意の tracker storage には登録されません — 登録される SP は `/breakdown` が書く subtask に属します)。

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — `/refine` は PO agent が所有。
- [Issue format](/policies/issue-format/) — `/refine` が生成する Background / Goal / AC / Out of Scope の形。
- [Issue size](/policies/issue-size/) — `suggest_split` を発火させる閾値。
- ライフサイクルの次: [`/breakdown`](/commands/breakdown/)。
- 正本の契約: [`commands/refine.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/refine.md)。
