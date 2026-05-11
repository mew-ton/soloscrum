---
title: Definition of Done
description: soloscrum subtask の Definition of Done チェックリスト。
sidebar:
  order: 5
---

`/review` が Pass verdict を出せる状態になるには、subtask が 6 つの条件をすべて満たしている必要がある。DoD は verdict コメントが照合する基準そのものだ。

## チェックリスト

- [ ] すべての AC が満たされている。
- [ ] テストが存在する (該当する場合)。
- [ ] PR 本文に Issue 番号が含まれる (`Closes #N` / `Fixes #N` / `Resolves #N` のいずれか)。
- [ ] lint エラーが 0。
- [ ] code review pipeline が実行され、finding に対処済み ([code review process](/ja/concept/code-review-process/) に従う)。
- [ ] review が pass している。

各項目について、「満たされた」とみなされる具体的な条件は別途決まっている。例えば「テストが存在する」はビジネスロジック、API endpoint、ユーティリティ関数には該当するが、ロジックを伴わない設定変更には該当しない。「Issue 番号」については、GitHub が auto-close キーワードとして認識する形式のいずれかが要求される。

## いつ適用されるか

タイミングは 2 つある:

- `/develop` 中、開発者 agent は「review が pass している」を除く全項目を self-check する。開発者が自分自身に review verdict を出すことはできない。
- `/review` 中、`/review` 自身が出そうとしている review pass を含む 6 項目すべてを検証する。verdict コメントには項目ごとに OK / Not OK とその理由が並ぶ。

## リポジトリ固有の追加項目

リポジトリは `.claude/rules/dod-extra.md` に独自の DoD 要件を追記できる。これらのエントリは core リストに **追加** されるもので、置き換えるものではない。

## 関連項目

- なぜ auto-close キーワードが必須なのか: [PR ライフサイクル](/ja/concept/pr-lifecycle/)。
- 正本の契約: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md)。
