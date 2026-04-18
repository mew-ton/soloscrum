# soloscrum-review-implementation

DoD照合・コード品質・クローズ判断を行う。

## 概要

PR または Figma ファイルを受け取り、DoD・AC・コード品質を評価する。Pass / Fail を判定し、Pass の場合はクローズ手続きを実行する。

## 手順

1. PR または Figma ファイルと対応 Issue を読み込む
2. `soloscrum-define-dod` の全項目を確認する
   - AC が全て満たされているか
   - テストが存在するか（対象がある場合）
   - PR 本文に Issue 番号が含まれるか
   - Lint エラーゼロか
3. コードレビュー（PR の場合）
   - ロジックの正確性
   - セキュリティ: OWASP Top 10 観点
   - パフォーマンス: 明らかなボトルネックがないか
   - 可読性・保守性
4. 全評価結果をまとめてレポートを作成する
5. **Pass 判定の場合**
   - PR にレビュー Approve
   - Linear subtask を Done に遷移
   - 全 subtask 完了確認
   - 全完了であれば GitHub Issue をクローズ
6. **Fail 判定の場合**
   - 具体的な指摘と改善案を PR にコメント
   - Linear subtask を In Progress に差し戻し

## 出力形式

```
## レビュー結果

### DoD チェック
- [x] AC が全て満たされている
- [x] テストが存在する
- [x] PR 本文に Issue 番号が含まれる
- [x] Lint エラーゼロ

### 指摘事項
- [あれば具体的に]

### 判定: Pass / Fail
```

## 依存スキル

- `soloscrum-define-dod`
