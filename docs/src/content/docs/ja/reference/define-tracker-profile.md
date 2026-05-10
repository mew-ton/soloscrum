---
title: define-tracker-profile
description: spec サマリ — tracker profile 解決、概念から保存場所への行列、operation skill の profile 名前空間化。
sidebar:
  order: 12
---

`soloscrum-define-tracker-profile` は、各 soloscrum 概念がどこに保存されるか、どうアクセスするか、agent と command が tracker operation を正しい skill にどうルーティングするかを — **tracker profile** ごとに — 定義します。

## 何をするか

次を固定します:

- 2 つの profile 値: `github-only` (デフォルト) と `linear+github`。
- 解決順序: リポジトリ override (`.claude/rules/tracker.md`) → ユーザ設定 (`.claude/settings.json` の `tracker_profile`) → ビルトインデフォルト (`github-only`)。
- 概念から保存場所への行列 (Issue, subtask, SP, state, 依存関係などが各 profile でどこにあるか)。
- operation skill 命名規約: `soloscrum-tracker-{github|linear}-{operation}`。別個の dispatcher は **ない** — 命名が dispatch そのもの。

## いつ消費されるか

tracker state を読み書きする必要があるすべての command と agent。彼らが最初に行うことは profile を解決することです; そこから先は `gh` や Linear MCP を直接呼ぶのではなく、マッチする `soloscrum-tracker-<profile>-<op>` skill を呼びます。

## 概念から保存場所への行列 (抜粋)

| 概念 | `github-only` | `linear+github` |
|---|---|---|
| Issue (parent) | GH Issue | GH Issue (canonical) |
| Subtask | GH Sub-issue (native) | Linear subtask (parent から同期) |
| Subtask ID | `#123` | `PRJ-42` |
| Subtask SP | GH Projects v2 `SP` Number フィールド | Linear `estimate` フィールド |
| Priority | GH `priority:*` ラベル | GH `priority:*` ラベル (GH が canonical) |
| State | GH `state:*` ラベル | Linear ネイティブ state |
| Dependency | `Depends on: #N` 本文行 | Linear "Blocked by" 関係 |

Issue (parent) は両 profile で **常に** GH Issue です。

## リポジトリ override

override ファイルのフォーマットはミニマルです:

```markdown
---
profile: github-only
---
```

ユーザレベルのデフォルトに関わらずリポジトリを特定の profile に固定するために `.claude/rules/tracker.md` に置きます。

## operation

profile ごとに 6 つの operation が存在します:

- `create-subtask`
- `transition-state`
- `set-sp`
- `query-backlog`
- `query-state`
- `add-dependency`

加えて profile 非依存の `wait-for-pr-checks` (PR は profile に関わらず GitHub 上にあります)。

operation ごとのサマリは [tracker operations](/reference/tracker-operations/) を参照。

## 関連項目

- 人間向けのウォークスルーは [tracker profile](/concept/tracker-profile/) を参照。
- 正本の契約: [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md)。
