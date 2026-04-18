---
name: soloscrum-define-design-criteria
description: Reference: criteria for validating feature design across scope clarity (Goal and AC alignment), dependency identification, and technical feasibility against the project stack.
user-invocable: false
---

# soloscrum-define-design-criteria

機能妥当性の判断基準。

## 評価観点

### 1. スコープの明確性

| チェック項目 | 基準 |
|---|---|
| Goal が 1〜2 文で明確に書かれているか | OK: 単一の目的。NG: 複数の目的が混在 |
| AC が検証可能な形式か | OK: "〜できる" 形式。NG: "〜を実装する" 形式 |
| Out of Scope が明示されているか | OK: 明示あり。NG: 空欄 |
| スコープが単一の機能に収まるか | OK: 1つの機能。NG: 複数機能が混在 |

### 2. 依存関係

| チェック項目 | 基準 |
|---|---|
| 他 Issue への依存が明示されているか | 依存がある場合は Notes に記載されているか |
| 外部 API・サービスへの依存はあるか | ある場合は利用可能かを確認する |
| データ変更（スキーマ変更等）を伴うか | 伴う場合はマイグレーションの考慮があるか |

### 3. 技術的妥当性

| チェック項目 | 基準 |
|---|---|
| 既存アーキテクチャと整合するか | 既存パターンから大きく外れる場合は要検討 |
| 技術スタックで実現可能か | `.claude/rules/stack.md` と照合する |
| パフォーマンス上の懸念はないか | 大量データ処理・リアルタイム処理等 |
| セキュリティ上の懸念はないか | 認証・認可・入力バリデーション等 |

## 判定基準

| 判定 | 条件 |
|---|---|
| **Pass** | 全項目 OK |
| **Conditional Pass** | 軽微な修正で解決できる指摘がある |
| **Fail** | スコープが不明確・技術的に実現困難・依存関係の問題がある |
