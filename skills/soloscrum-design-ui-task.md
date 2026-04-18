---
name: soloscrum-design-ui-task
description: Designs a Linear subtask (type design-ui) in Figma with design tokens, components, all component states, and state transition diagrams. Checks DoD on completion.
argument-hint: <subtask-id>
disable-model-invocation: true
---

# soloscrum-design-ui-task

Figma制作・トークン・パターン構築を行う。

## 概要

Linear subtask（type: design-ui）の AC に基づき Figma でデザインを制作する。`soloscrum-define-ui-standards` の規約に従う。

## 手順

1. subtask の AC・説明・関連 Issue を読み込む
2. `soloscrum-define-ui-standards` でデザイントークン・パターン規約を確認する
3. Figma MCP で制作する
   - 既存コンポーネントの確認と再利用
   - 新規コンポーネントの制作（必要な場合）
   - デザイントークンの適用
   - UIパターンの整合性確認
4. 全 State を定義する
   - Default / Hover / Focus / Active / Disabled / Error / Loading（該当するもの）
5. State 遷移図の作成（インタラクションがある場合）
6. アクセシビリティ確認
   - コントラスト比: WCAG AA 以上
   - タッチターゲット: 44px × 44px 以上
7. `soloscrum-define-dod` で DoD を確認する

## 出力

- Figma ファイル URL
- 制作したコンポーネント一覧
- 適用したデザイントークン一覧

## 依存スキル

- `soloscrum-define-ui-standards`
- `soloscrum-define-dod`
