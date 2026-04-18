---
name: breakdown
description: Breaks a GitHub Issue into Linear subtasks with type (develop or design-ui) and story points. Proposes the breakdown for confirmation before registering in Linear.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# /breakdown

IssueをLinear subtaskに分解しタイプを付与する。

## 動作

1. 対象 Issue を受け取る（`$ARGUMENTS`）
2. `design-agent` が粒度・タイプ設計を実行
   - subtask への分解方針を策定
   - 各 subtask にタイプ付与（`soloscrum-define-task-type` 基準）
   - `soloscrum-validate-feature` で分解の妥当性を確認
3. ユーザーに分解案を提示・確認
4. 承認後、`dev-agent` が Linear MCP で subtask を登録
   - SP 算出（`soloscrum-define-story-points` 基準）
   - タスクタイプをラベルとして付与

## 入力

- GitHub Issue URL または Issue 番号

## 出力

- 作成された Linear subtask リスト
  - タイトル
  - タイプ（develop / design-ui）
  - SP
  - 説明

## 使用リソース

- Subagents: `design-agent`（粒度・タイプ設計）, `dev-agent`（subtask 登録）
- Skills: `soloscrum-validate-feature`, `soloscrum-define-task-type`, `soloscrum-split-into-tasks`, `soloscrum-define-story-points`
