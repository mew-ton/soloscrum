---
name: soloscrum-split-into-tasks
description: Breaks a GitHub Issue into Linear subtasks with type (develop or design-ui) and story point estimates. Registers subtasks via Linear MCP after user approval.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# soloscrum-split-into-tasks

Issueをsubtaskへ分解・タイプ付与・SP算出する。

## 概要

Issue の AC と Goal をもとに、実装可能な subtask に分解する。各 subtask にタイプ（develop / design-ui）と SP を付与し、Linear に登録する。

## 手順

1. Issue の AC・Goal・Out of Scope を読み込む
2. AC を実装単位に分解する
   - 1 subtask = 単一の明確な成果物
   - subtask 間の依存関係を整理する
   - `soloscrum-define-task-type` でタイプを付与する
3. 各 subtask の SP を算出する（`soloscrum-define-story-points` 参照）
4. subtask 数が `soloscrum-define-issue-size` の `max_subtasks` を超える場合はユーザーに確認する
5. ユーザー承認後、Linear MCP で subtask を登録する
   - parent: 対象 Issue の Linear Task
   - title: subtask タイトル
   - type label: develop または design-ui
   - estimate: SP

## 出力形式

```
## subtask 分解案

| # | タイトル | タイプ | SP |
|---|---------|--------|-----|
| 1 | [タイトル] | develop | 2 |
| 2 | [タイトル] | design-ui | 1 |

合計 SP: 3
```

## 依存スキル

- `soloscrum-define-task-type`
- `soloscrum-define-story-points`
- `soloscrum-define-issue-size`
