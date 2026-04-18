---
name: soloscrum-validate-feature
description: Validates a feature's design for scope clarity, dependencies, and technical feasibility. Returns Pass/Conditional Pass/Fail with recommended actions.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# soloscrum-validate-feature

機能設計の妥当性・スコープ・依存関係を検証する。

## 概要

Issue または機能設計を受け取り、`soloscrum-define-design-criteria` の基準で妥当性を検証する。問題点と推奨アクションを返す。

## 手順

1. 対象 Issue の内容を読み込む: $ARGUMENTS
2. 以下の観点で評価する（`soloscrum-define-design-criteria` 参照）

   **スコープ評価**
   - Goal と AC が一致しているか
   - Out of Scope が明示されているか
   - スコープが曖昧な部分はないか

   **依存関係評価**
   - 他の Issue・機能への依存があるか
   - 外部 API・サービスへの依存があるか
   - 先行して完了すべき作業があるか

   **技術的妥当性**
   - 既存のアーキテクチャと整合するか
   - `.claude/rules/stack.md` の技術スタックで実現可能か
   - パフォーマンス・セキュリティ上の懸念はないか

3. 評価結果を構造化して返す

## 出力形式

```
## 妥当性検証結果

### スコープ
- 状態: OK / 要修正
- 指摘: [あれば]

### 依存関係
- [依存先1]: [説明]

### 技術的懸念
- [懸念点1]: [詳細と推奨対応]

### 総合判定: Pass / Conditional Pass / Fail
推奨アクション: [次にすべきこと]
```

## 依存スキル

- `soloscrum-define-design-criteria`
