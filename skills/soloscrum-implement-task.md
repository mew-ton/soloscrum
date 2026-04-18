---
name: soloscrum-implement-task
description: Implements a Linear subtask (type develop) by creating a branch, writing code and tests, committing with Conventional Commits, generating a PR body, and creating the PR.
argument-hint: <subtask-id>
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash
---

# soloscrum-implement-task

コード実装・PR本文生成を行う。

## 概要

Linear subtask（type: develop）の AC に基づきコードを実装し、PR を生成する。`soloscrum-define-branch-commit` の規約に従う。

## 手順

1. subtask の AC・説明・関連 Issue を読み込む
2. `.claude/rules/stack.md` で技術スタックを確認する
3. `soloscrum-define-branch-commit` の規約でブランチを作成する
   - `{type}/{issue-id}-{slug}`
4. AC を満たすコードを実装する
   - テストを作成する（対象がある場合）
   - Lint エラーがないことを確認する
5. Conventional Commits 形式でコミットする
6. PR 本文を生成する

   ```markdown
   ## Summary
   [変更の概要]

   ## Changes
   - [変更点1]

   ## Test
   [テスト方法]

   Closes #[Issue番号]
   ```

7. PR を作成する
8. `soloscrum-define-dod` で DoD を確認する

## 依存スキル

- `soloscrum-define-branch-commit`
- `soloscrum-define-dod`
