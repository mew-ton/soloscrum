---
title: define-ui-standards
description: spec サマリ — design token カテゴリ、命名規約、必須 component state、WCAG AA accessibility 要件。
sidebar:
  order: 13
---

`soloscrum-define-ui-standards` は、`soloscrum-ui` (および `/breakdown` 中の design パス) が Figma 成果物と design token を生成するときに従う規約 skill です。

## 何をするか

3 グループの規約を固定します:

1. **design token** — カテゴリ (`color`, `typography`, `spacing`, `radius`, `shadow`, `motion`) と命名規約 `{category}/{semantic}/{variant}` (例: `color/brand/primary`, `typography/body/md`, `spacing/component/md`)。
2. **component state** — すべてのインタラクティブ component は Default、Hover (desktop)、Focus (accessibility)、Disabled (該当時)、Loading (非同期時)、Error (バリデーション存在時) を定義しなければならない。Active / Pressed はオプション。
3. **accessibility** — WCAG AA コントラスト (通常テキストで 4.5:1、大きい 18px+ テキストで 3:1)、最小 44 × 44px のタッチターゲット、可視 focus indicator。

## いつ消費されるか

`soloscrum-design-ui-task` (`/design-ui` の裏側のエンジン) が直接これを読みます。Design agent も `/breakdown` 中に UI subtask を提案するときに参照します。

## 主要な入力と出力

入力は subtask AC と既存の Figma ファイル (component, token) です。出力はすべての必須 state が定義され、命名規約に従って token が適用され、accessibility check に通った Figma 成果物です。

## 新しいパターンの追加

既存パターンが use case をカバーできない場合:

1. 新しいパターンを作成する前にユーザに確認する。
2. Figma component ライブラリに追加する。
3. その命名と使用基準を Figma component の説明に文書化する。

## 注記

skill は汎用的な初期値を同梱します。プロジェクト固有の token とパターンは、プロジェクトの Figma ファイルまたは `.claude/rules/` でこれらを override すべきです。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-ui-standards/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-ui-standards/SKILL.md)。
- この skill の起動を駆動する type (`design-ui`) については、[`define-task-type`](/reference/define-task-type/) を参照。
