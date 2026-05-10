---
title: Definition of Done
description: soloscrum subtask の Definition of Done チェックリスト。
sidebar:
  order: 5
---

すべての subtask は `/review` が Pass verdict を出せる前に 6 つの条件を満たす必要があります。DoD は verdict コメントが照合する基準そのものです。

## チェックリスト

- [ ] すべての AC が満たされている。
- [ ] テストが存在する (該当する場合)。
- [ ] PR 本文に Issue 番号が含まれる (`Closes #N` / `Fixes #N` / `Resolves #N`)。
- [ ] lint エラーがゼロ。
- [ ] code review pipeline が実行され finding に対処済み ([code review process](/ja/concept/code-review-process/) に従う)。
- [ ] review が pass している。

各項目について、何が「満たされた」とカウントされるかは具体的に定義されています — 例えば「テストが存在する」はビジネスロジック / API endpoint / ユーティリティ関数には該当しますが、ロジックなしの設定変更には該当しません。「Issue 番号」は GitHub が認識する auto-close キーワードのいずれかを具体的に要求します。

## いつ使われるか

2 つの瞬間があります:

- `/develop` 中、開発者 agent は「review が pass している」以外のすべての項目について self-check を行います — 開発者は自分自身に review verdict を発行できません。
- `/review` 中、6 項目すべて (`/review` 自身が発行しようとしている review pass を含む) が検証されます。verdict コメントには項目ごとの OK / Not OK と理由が並びます。

## リポジトリ固有の追加項目

リポジトリは `.claude/rules/dod-extra.md` に独自の DoD 要件を追加できます。それらのエントリは core リストに **追加** されるもので、置き換えるものではありません。

## 関連項目

- auto-close キーワードが必須な理由: [PR ライフサイクル](/ja/concept/pr-lifecycle/)。
- 正本の契約: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md)。
