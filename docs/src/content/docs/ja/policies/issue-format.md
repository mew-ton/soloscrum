---
title: Issue フォーマット
description: Issue タイトルと本文の必須形 (Background / Goal / Acceptance Criteria / Out of Scope) と コンパニオンの ISSUE_TEMPLATE ファイル。
sidebar:
  order: 1
---

soloscrum の Issue 本文は常に同じ 4 セクション構造を取ります: Background / Goal / Acceptance Criteria / Out of Scope。`/refine` がこの形で Issue を生成し、あなたは承認前に本文を読み・編集します。後段の `/validate` と `/breakdown` は形が予測可能であることに依存します。

## 4 つのセクション

本文は常にこの順序で書かれます:

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

- 動詞で始まる、50 文字以下
- How ではなく What を記述する

AC のルール:

- 各項目が独立して検証可能
- ユーザ視点の言い回し (「user can …」「… is displayed」) ― 実装の言い回し (「Issue JWT token」「Implement validation」) は使わない

先頭の `<!-- soloscrum-issue-format -->` HTML コメントと最下部の小さなイタリック footer は、本文が soloscrum 形式であることを示すマーカーで、janitor や `/validate` が安価に検出できるようにします。

## いつ使われるか

`/refine` がこの形で Issue を書き、`/breakdown` の前に `/validate` が既存 Issue を同じ形に対してチェックします。triage / 見積もり / pickup のたびに、あなたもこの本文を読みます。

## コンパニオンテンプレート

コンパニオンファイル `templates/ISSUE_TEMPLATE.md` は本文構造をミラーし、次のいずれかが可能です:

- `.github/ISSUE_TEMPLATE/` にコピーすると GitHub の「New Issue」UI が chooser エントリとして提示する、**または**
- GitHub Web UI の新しい Issue 本文に手動で貼り付ける。

正本の言語は英語です。多言語版は out of scope です。

## 関連項目

- この形式の本文に対するサイズ上限: [`issue-size`](/policies/issue-size/)。
- 正本の契約: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md)。
