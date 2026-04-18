# /review

実装・デザインをレビューしIssueをクローズする。

## 動作

1. 対象 PR または Figma ファイルを受け取る
2. `review-agent` を起動し以下を実行させる
   - `soloscrum-define-dod` と `.claude/rules/dod-extra.md` で DoD 照合
   - コード品質チェック（PR の場合）
   - Issueの AC（Acceptance Criteria）全件確認
   - 問題点の指摘とレビューコメント
3. オプション: `design-agent` で機能スコープ逸脱チェック
4. オプション: `ui-agent` でデザイン再現性チェック
5. Pass 判定の場合:
   - PR マージ承認
   - Linear subtask を Done にステート遷移
   - 全 subtask 完了時、GitHub Issue をクローズ

## 入力

- PR URL / 番号 または Figma ファイル URL
- 対応する GitHub Issue 番号（省略時は PR の本文から抽出）

## 出力

- レビュー結果レポート
  - DoD チェックリスト
  - 指摘事項リスト（あれば）
  - Pass / Fail 判定
- Pass 時: Issue クローズ確認

## 使用リソース

- Subagents: `review-agent`（必須）, `design-agent`（オプション）, `ui-agent`（オプション）
- Skills: `soloscrum-review-implementation`, `soloscrum-define-dod`
- Rules: `.claude/rules/dod-extra.md`
