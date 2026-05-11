---
title: Issue フォーマット
description: Issue のタイトルと本文に求められる構造 (Background / Goal / Acceptance Criteria / Out of Scope)、および付属の ISSUE_TEMPLATE ファイル。
sidebar:
  order: 1
---

soloscrum の Issue 本文は、常に 4 セクションの同じ並びを取る: Background、Goal、Acceptance Criteria、Out of Scope。`/refine` がこの形で本文を生成し、ユーザは承認前にそれを読んだり編集したりする。後段の `/validate` と `/breakdown` は、本文の構造が予測可能であることに依存している。

## 4 つのセクション

本文は常にこの順番で書く:

```markdown
## Background
[Why this feature is needed.]

## Goal
[State the objective in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable condition. Use "user can ..." format.]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing.]

## Notes
[Supplementary info, references, design links.]
```

タイトルのルール:

- 動詞で始め、50 文字以内に収める
- How ではなく What を書く

AC のルール:

- 各項目は独立して検証可能であること
- 表現はユーザ視点 (「user can …」「… is displayed」) を採る。実装視点 (「Issue JWT token」「Implement validation」) は使わない

本文冒頭の `<!-- soloscrum-issue-format -->` HTML コメントと、末尾の小さなイタリック footer が、その本文を soloscrum フォーマットと見分けるためのマーカーだ。janitor や `/validate` はこれを使って安価に判定できる。

## いつ適用されるか

`/refine` はこの形で Issue を書く。`/breakdown` の前に `/validate` が既存 Issue を同じ形に照らしてチェックする。triage、見積もり、pickup の場面でもこの本文を読むことになる。

## コンパニオンテンプレート

付属の `templates/ISSUE_TEMPLATE.md` は同じ本文構造をミラーしており、次のどちらの使い方もできる:

- `.github/ISSUE_TEMPLATE/` にコピーする。これで GitHub の「New Issue」UI に chooser エントリとして表示される。**または**
- GitHub Web UI 上の新規 Issue 本文に手で貼り付ける。

正本の言語は英語だ。多言語版は out of scope。

## 関連項目

- この形式の本文に適用されるサイズ上限: [`issue-size`](/ja/policies/issue-size/)。
- 正本の契約: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md)。
