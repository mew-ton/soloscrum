---
name: develop
description: Implements a Linear subtask of type develop. Creates a branch, writes code and tests, generates a PR, and transitions the subtask to In Review.
argument-hint: <subtask-id>
disable-model-invocation: true
effort: high
---

# /develop

develop subtaskを実装する。

## 動作

1. 対象 Linear subtask（type: develop）を受け取る（`$ARGUMENTS`）
2. `dev-agent` を起動し以下を実行させる
   - `soloscrum-define-branch-commit` 規約に従いブランチ作成
   - `.claude/rules/stack.md` を参照してコード実装
   - `soloscrum-define-dod` と `.claude/rules/dod-extra.md` で DoD 確認
   - PR 本文生成（Issue 番号・変更概要・テスト方法）
   - PR 作成
3. Linear subtask を In Review にステート遷移
4. ユーザーに PR URL を提示

## 入力

- Linear subtask URL または ID
- （省略時）Linear の In Progress 状態の subtask を自動選択

## 出力

- 作成された PR URL
- 実装サマリー
- DoD チェックリスト結果

## 使用リソース

- Subagent: `dev-agent`
- Skills: `soloscrum-implement-task`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`
