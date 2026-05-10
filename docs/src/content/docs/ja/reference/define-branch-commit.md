---
title: define-branch-commit
description: spec サマリ — soloscrum の branch 命名と Conventional Commit 規約。
sidebar:
  order: 2
---

`soloscrum-define-branch-commit` は branch と commit の命名契約です。`/develop` と review pipeline の両方がこれを読みます; branch または commit メッセージが一致しない場合、それは Fail の根拠になります。

## 何をするか

次を固定します:

- branch 名のフォーマット `{type}/{issue-id}-{slug}`。
- `{type}` の語彙: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`。
- アクティブな tracker profile に応じた `{issue-id}` の形 (`github-only` では GitHub issue 番号、`linear+github` では `PRJ-42` のような Linear ID)。
- slug ルール: kebab-case、小文字 / 数字 / ハイフンのみ、最大 30 文字。
- commit は [Conventional Commits](https://www.conventionalcommits.org/) に従う — `{type}({scope}): {description}` でオプションの body と footer。

## いつ消費されるか

`soloscrum-implement-task` (`/develop` の裏側のエンジン) は、これらのルールを使って branch と最初の commit を作成します。review pipeline は DoD 検証時に branch 名と PR の commit リストを読みます; Conventional でない commit やフォーマットに一致しない branch は finding として浮上します。

## 主要な入力と出力

入力は issue / subtask の ID、その title (slug になる)、そして commit type (commit の意図から取られる) です。出力は契約に従う branch 参照と 1 つ以上の commit メッセージです。

## 例

```text
feat/123-user-password-reset
fix/PRJ-42-auth-token-expiry
refactor/47-concept-reference-docs
```

```text
feat(auth): add password reset endpoint

Implements the POST /auth/reset-password endpoint with email
verification flow.

Closes #123
```

## 注記

- `.claude/rules/branch.md` のリポジトリ固有の branch 戦略が優先されます。
- `main` / `master` に直接 commit しないでください。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-branch-commit/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md)。
- branch 作成がライフサイクルのどこに位置するかは、[agent と責務](/concept/agent-responsibilities/) を参照。
