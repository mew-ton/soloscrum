---
title: Definition of Done
description: soloscrum subtask の Definition of Done チェックリスト。
sidebar:
  order: 5
---

`soloscrum-define-dod` は Definition of Done — `/review` が Pass verdict をレンダリングする前にすべての subtask が満たさなければならない 6 項目のチェックリストです。

## 何をするか

正本の DoD リストを固定します:

- [ ] すべての AC が満たされている。
- [ ] テストが存在する (該当する場合)。
- [ ] PR 本文に Issue 番号が含まれる (`Closes #N` / `Fixes #N` / `Resolves #N`)。
- [ ] lint エラーがゼロ。
- [ ] code review pipeline が実行され finding に対処済み ([code review process 概念](/concept/code-review-process/) に従う)。
- [ ] review が pass している。

各項目について、skill は何が「満たされた」とカウントされるかを綴ります — 例えば「テストが存在する」はビジネスロジック、API endpoint、ユーティリティ関数には該当しますが、ロジックなしの設定変更には該当しません。「Issue 番号」は GitHub が認識する auto-close キーワードのいずれかを具体的に要求します。

## いつ消費されるか

2 つの caller:

- `soloscrum-implement-task` (`/develop`) は「review が pass している」以外のすべての項目について self-check を行います — 開発者 agent は self で review verdict を発行できません。
- `soloscrum-review-implementation` (`/review`) は 6 項目すべて (自分自身が発行しようとしている review pass を含む) を検証します。

## 主要な入力と出力

入力は PR (本文、diff、commit リスト、lint 出力、テスト結果) とリンクされた Issue の AC です。出力は項目ごとの OK / Not OK と理由で、code review finding と並んで `/review` コメントに浮上します。

## リポジトリ固有の追加項目

リポジトリは `.claude/rules/dod-extra.md` に独自の DoD 要件を追加できます。それらのエントリは core リストに **追加** されるもので、置き換えるものではありません。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md)。
- Issue 番号の auto-close キーワードが強制される理由は、Issue クロージャと merge の相互作用にあります — [PR ライフサイクル](/concept/pr-lifecycle/) を参照。
