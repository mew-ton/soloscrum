---
title: define-task-type
description: spec サマリ — subtask 種別 `develop` と `design-ui`、割り当て基準、UI 機能は分割必須というルール。
sidebar:
  order: 11
---

`soloscrum-define-task-type` は、subtask が正確に 2 種類で来ること、そして UI 機能は常に design-then-develop のペアに分割されることを定める、小さくも重要なルールです。

## 何をするか

2 つの type 値とそれぞれを所有する agent を固定します。

| Type | 定義 | 割り当てられる agent |
|---|---|---|
| `develop` | コード変更を伴うすべての作業 | `soloscrum-dev` |
| `design-ui` | Figma、design token、UI パターン作業 | `soloscrum-ui` |

type は subtask 上のラベルとして存在します: `type:develop` または `type:design-ui`。`github-only` では Sub-issue 上の GH ラベル、`linear+github` では subtask 上の Linear ラベルです。ラベル値は profile 間で同一です。

## 割り当て基準

backend 実装、frontend 実装、component の振る舞い、test、infrastructure 設定には **`develop`** を割り当てます。

新しい Figma component 制作、design token の定義と更新、UI パターンの定義、画面遷移 / 状態フロー設計には **`design-ui`** を割り当てます。

## 分割ルール

単一の subtask が両方の type を持つことはありえません。機能が UI を持つ場合:

- 先に `design-ui` subtask を作成する。
- `develop` subtask が後続し、それに依存する — design subtask が review されて完了するまで開始しない。

これにより Figma の source of truth が実装に先行し、開発者 agent が designer agent の意図と矛盾する UI を発明する failure mode を回避します。

## いつ消費されるか

`soloscrum-split-into-tasks` (`/breakdown`) は、提案する各 subtask に type を割り当てるときにこの skill を呼びます。Dev agent は `soloscrum-tracker-{github|linear}-create-subtask` 経由で subtask を登録するときに対応するラベルを適用します。

## 主要な入力と出力

入力は subtask の AC と意図です。出力は `develop` / `design-ui` のいずれかと、対応するラベルです。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-task-type/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-task-type/SKILL.md)。
- `design-ui` subtask が参照する UI トークンとパターン規約については、[`define-ui-standards`](/reference/define-ui-standards/) を参照。
