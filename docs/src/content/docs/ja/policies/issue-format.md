---
title: Issue フォーマット
description: Issue タイトルと本文の必須形 (Background / Goal / Acceptance Criteria / Out of Scope) と コンパニオンの ISSUE_TEMPLATE ファイル。
sidebar:
  order: 1
---

`soloscrum-define-issue-format` は、すべての soloscrum Issue が従う構造的契約です。`/refine` はこの形で Issue を生成し、`/validate` と `/breakdown` は形が予測可能であることに依存します。

## 何をするか

次を固定します:

- title ルール: 動詞で始まる、50 文字以下、How ではなく What を記述する。
- 本文セクション、順序通り: `## Background`, `## Goal`, `## Acceptance Criteria` (チェックボックス), `## Out of Scope`, オプションで `## Notes`。
- AC 記述ルール — 検証可能でユーザ向けの言い回し (「user can …」/「… is displayed」)、実装の言い回しではない (「Issue JWT token」/「Implement validation」)。
- soloscrum 形式 Issue の self-marker: 先頭の `<!-- soloscrum-issue-format -->` HTML コメントと最下部の小さなイタリック footer。

## いつ消費されるか

`soloscrum-create-issue` (`/refine`) は、この spec から直接 Issue 本文を生成します。`soloscrum-validate-feature` (`/validate`) は同じ形に対して生成された Issue をチェックします。コンパニオンの `templates/ISSUE_TEMPLATE.md` は、人間が GitHub UI 経由で使うために skill の隣に置かれています — `/refine` 自体はこれを **読みません**; 2 つの面は手動で同期されます。

## 主要な入力と出力

`/refine` への入力は自由形式のアイデアです。出力は上記構造に従う GitHub Issue 本文です:

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

## コンパニオンテンプレート

コンパニオンファイル `templates/ISSUE_TEMPLATE.md` は本文構造をミラーし、次のいずれかが可能です:

- `.github/ISSUE_TEMPLATE/` にコピーすると GitHub の「New Issue」UI が chooser エントリとして提示する、**または**
- GitHub Web UI の新しい Issue 本文に手動で貼り付ける。

正本の言語は英語です。多言語版は out of scope です。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md)。
- この形式の Issue を分割すべきかどうかを判断する size gate は [`issue-size`](/policies/issue-size/) にあります。
