---
name: soloscrum-define-dod
description: Reference: soloscrum Definition of Done checklist. All AC satisfied, tests exist if applicable, PR body links issue number with Closes/Fixes, lint passes, review approved.
user-invocable: false
---

# soloscrum-define-dod

Definition of Done（汎用）。

## DoD チェックリスト

- [ ] ACが全て満たされている
- [ ] テストが存在する（対象がある場合）
- [ ] PR本文にIssue番号が含まれる（`Closes #N` または `Fixes #N` 形式）
- [ ] Lintエラーゼロ
- [ ] レビューがpassしている

## 各項目の判断基準

### AC が全て満たされている
- Issue に記載された全ての AC チェックボックスが満たされている
- 動作確認済みで証跡がある（スクリーンショット・テスト結果等）

### テストが存在する（対象がある場合）
- 対象がない場合: ロジックを持たない設定変更・ドキュメント修正等
- 対象がある場合: ビジネスロジック・API エンドポイント・ユーティリティ関数等

### PR 本文に Issue 番号が含まれる
- `Closes #123` / `Fixes #123` / `Resolves #123` のいずれかが本文に存在する

### Lint エラーゼロ
- プロジェクトの Lint 設定（ESLint・Prettier・Rubocop等）でエラーが出ない
- Warning は許容するが、エラーは不可

### レビューがpassしている
- `review-agent` による自動レビューで Pass 判定を得ている

## リポジトリ固有の追加 DoD

`.claude/rules/dod-extra.md` で定義する（soloscrum 本体には含めない）。
