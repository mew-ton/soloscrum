---
title: Issue フォーマット
description: Issue のタイトルと本文に求める形 (Background / Goal / Acceptance Criteria / Out of Scope)、および付属の ISSUE_TEMPLATE ファイルについて説明します。
sidebar:
  order: 1
---

soloscrum の Issue は、本文がすべて Background / Goal / Acceptance Criteria / Out of Scope の 4 セクション構成です。この形を書き出すのが `/refine`、形が揃っていることを前提に動くのが `/validate` と `/breakdown` です。

## 4 つのセクション

本文は常に次の順序で書きます。

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

- 動詞から始める
- 50 文字以内
- What を書く (How は書かない)

AC のルール:

- 1 項目ずつ独立して検証できる
- ユーザ視点の表現にする (`user can …` / `… is displayed` など)。実装視点の表現 (`Issue JWT token` / `Implement validation` など) は使わない

本文の先頭には `<!-- soloscrum-issue-format -->` の HTML コメントと、小さなイタリック体のフッタが付きます。これにより janitor や `/validate` は、その Issue が soloscrum フォーマットで書かれているかどうかを軽く判定できます。

## 適用される場面

- `/refine` がこの形で Issue を作成します
- `/breakdown` を走らせる前に、`/validate` が既存 Issue がこの形になっているかを確認します
- Issue を triage、見積もり、ピックアップする際の読み手側の前提でもあります

## 付属テンプレート

`templates/ISSUE_TEMPLATE.md` は本文構造をそのまま写したテンプレートです。使い方は 2 通りあります。

- `.github/ISSUE_TEMPLATE/` 配下にコピーすれば、GitHub の「New Issue」UI でチューザーに表示されます
- GitHub web UI で新規 Issue を開き、本文に手動でペーストします

canonical な言語は英語です。多言語版は対象外です。

## 参考

- この形式で書かれた本文に対するサイズ上限: [`issue-size`](/ja/policies/issue-size/)
- canonical な契約: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md)
