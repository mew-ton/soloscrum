---
name: refine
description: Structures an idea into a GitHub Issue. Checks size, suggests splitting when too large, determines priority and SP, then creates the issue after confirmation.
argument-hint: <idea or feature description>
disable-model-invocation: true
---

# /refine

アイデアをIssueに構造化する。

## 動作

1. ユーザーからアイデアや要望を受け取る（`$ARGUMENTS`）
2. `po-agent` を起動し以下を実行させる
   - アイデアを GitHub Issue 形式に構造化
   - 粒度チェック（`soloscrum-define-issue-size` 基準）
   - 粒度超過の場合は分割提案
   - 優先度判定（`soloscrum-define-priority` 基準）
   - SP 算出（`soloscrum-define-story-points` 基準）
3. ユーザーに構造化結果を提示・確認
4. 承認後、GitHub Issue を作成
5. Linear 自動同期後、Linear MCP で SP・優先度をセット

## 入力

- アイデア・要望のテキスト（自由形式）

## 出力

- 作成された GitHub Issue URL
- Linear Task URL（同期後）
- 設定された SP・優先度

## 使用リソース

- Subagent: `po-agent`
- Skills: `soloscrum-create-issue`, `soloscrum-define-issue-format`, `soloscrum-define-issue-size`, `soloscrum-define-priority`
