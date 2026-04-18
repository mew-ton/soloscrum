# /validate

機能設計の妥当性を検証する。

## 動作

1. 対象 Issue（またはアイデア）を受け取る
2. `design-agent` を起動し以下を実行させる
   - 機能設計の妥当性評価（`soloscrum-define-design-criteria` 基準）
   - スコープの明確性チェック
   - 依存関係の洗い出し
   - 技術的実現可能性の評価
3. 検証結果をユーザーに提示
4. 問題があれば修正案を提案

## 入力

- GitHub Issue URL または Issue 番号
- Issue 本文（直接テキストでも可）

## 出力

- 妥当性評価レポート
  - スコープ明確性: OK / 要修正
  - 依存関係リスト
  - 技術的懸念点（あれば）
  - 推奨アクション

## 使用リソース

- Subagent: `design-agent`
- Skills: `soloscrum-validate-feature`, `soloscrum-define-design-criteria`
