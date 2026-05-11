---
title: /refine
description: 自由形式のアイデアを GitHub Issue に構造化する。事前に backlog janitor sweep を走らせ、すでに closing PR が merge された open Issue をクローズする。
sidebar:
  order: 1
---

`/refine` は入口だ。1 文、1 段落、あるいは形になりきっていない bug report — どんなアイデアを渡しても、soloscrum の他の command が読み解ける Background / Goal / Acceptance Criteria / Out of Scope の構造に整った GitHub Issue が出てくる。Issue を作る前に、closing PR がすでに merge された stale-open な Issue を backlog から一掃する。

## Usage

```bash
/refine <idea or feature description> [--no-janitor]
```

引数は自由テキストでよい。`--no-janitor` を付けると backlog sweep をスキップする。GitHub API が不安定なとき、または command 開始時の出力をすっきりさせたいときに便利だ。

## 何が起きるか

1. **Backlog janitor.** `/refine` は open Issue を走査し、closing keyword (`Closes #N`、`Fixes #N`、`Resolves #N` など) で参照していてすでに merge 済みの PR がないかを各 Issue について確認する。該当する PR を持つ Issue は reason `completed` でクローズされる。出力の 1 行目は `Closed N stale Issue(s): #X, #Y`、または `No stale Issues found`、`--no-janitor` を渡したときは `Janitor skipped` のいずれかになる。janitor はクローズしかしない — 再オープンは絶対にしない。
2. **アイデアの構造化.** PO agent がアイデアを読み、4 セクションの Issue 本文を組み立て、[priority](/ja/policies/priority/) ラベルを選び、size-check の [SP](/ja/policies/story-points/) を計算する。
3. **Size gate.** size-check SP が 5 を超えると、`/refine` は Issue を oversized として flag し、作成前に分割を提案する。閾値の詳細は [issue size](/ja/policies/issue-size/) を参照。
4. **承認待ち.** 構造化された Issue 本文をユーザに見せて、承認を待つ。
5. **Issue 作成.** 承認されると、priority ラベル付きで GitHub Issue を作成する。

## 典型的な流れ

セッションは「*users should be able to reset their password by email*」のようなアイデアから始まる、というのが典型例だ。`/refine "users should be able to reset their password by email"` を実行する。1 行目の出力は janitor の結果で、クリーンな repo ならふつう `No stale Issues found` になる。続いて PO agent が構造化済みの Issue 本文を提示する: ユーザのニーズを説明する Background 段落、1 文の Goal、3〜5 個の AC チェックボックス、そしてその Issue が意図的にカバーしないものを書き出した明示的な Out of Scope。priority (初日からユーザが触れる feature なら `high` あたり) と size-check SP も併せて surface される。

SP が 5 以下ならユーザが承認し、Issue が作成される。authentication / email インフラ / password form UI をまたぐ変更で SP が 8 と返ってきたら、command は Issue が大きすぎることを伝え、feature 軸での分割を提案する。ここでユーザは、分割した各ピースについて `/refine` を再実行するか、単一 Issue の scope を維持する意味があるなら `/breakdown` に進んで subtask に分けるか、どちらかを選ぶことになる。

新しい Issue を追加していないセッションでも、`/refine` は出発点として自然な場所だ。janitor sweep が backlog を最新に保つので、次に取りかかるものが「open に偽装されたすでに ship 済みの作業」ではないと保証される。

## Output

- 1 行目: janitor の summary。
- 作成された GitHub Issue の URL。
- 適用された priority ラベル。
- size-check SP (informational。tracker storage には登録されない — 登録される SP は `/breakdown` が書き込む subtask の側に属する)。

## 関連項目

- [agent と責務](/ja/concept/agent-responsibilities/) — `/refine` は PO agent が所有する。
- [Issue フォーマット](/ja/policies/issue-format/) — `/refine` が生成する Background / Goal / AC / Out of Scope の形。
- [Issue サイズ](/ja/policies/issue-size/) — `suggest_split` を発火させる閾値。
- ライフサイクルの次のステップ: [`/breakdown`](/ja/commands/breakdown/)。
- 正本の契約: [`commands/refine.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/refine.md)。
