---
title: /develop
description: develop Subtask を実装します。ブランチを切り、コードを書き、draft PR を開き、Subtask を in-review に進めます。
sidebar:
  order: 3
---

`/develop` は `type:develop` の Subtask を実装します。soloscrum の命名規約でブランチを切り、実装を書き、[DoD](/ja/policies/dod/) を自己チェックし、**draft** PR を開きます。draft が開いた時点で、Subtask の state は `in-progress` から `in-review` に進みます。

## 使い方

```bash
/develop <subtask-id>
```

引数は Subtask の URL または ID (`github-only` なら `#N`、`linear+github` なら `PRJ-N`) です。省略すると、active tracker の query skill で `in-progress` の Subtask を自動選択します。

## 処理の流れ

1. **Subtask を読む。** Dev agent が Subtask AC、親 Issue、`.claude/rules/*.md` 配下のオーバーライド (stack / branch 戦略 / DoD の追加項目) を読みます。
2. **ブランチを切る。** [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の規約に従い、`<type>/<issue-id>-<slug>` (例: `feat/123-password-reset`) の形でブランチを作ります。
3. **実装する。** Conventional Commits (`feat: …` / `fix: …` / `refactor: …`) で commit を重ねます。
4. **DoD 自己チェック。** Dev が担当できる DoD 項目をすべて確認します — AC が満たされている、必要な箇所にテストがある、lint がクリーン、PR 本文に Issue の closing keyword が入る予定。「review が pass している」だけは Dev が自分で出せず、`/review` の担当です。
5. **draft で PR を開く。** `gh pr create --draft` がここの境界です。GitHub 側 reviewer が動く前に local の quality gate を回す窓を確保するため、PR は常に draft で始まります ([PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照)。
6. **CI が起動したことを確認する。** wait-for-checks スクリプトを短いタイムアウト (例: 300 秒) で走らせます。狙いは「CI 起動時の失敗 (workflow syntax error、secret 不足など) をこの段階で表面化させ、`/review` で初めて気付く事態を避ける」ことです。green を待つことではありません。
7. **state を進める。** active tracker の transition skill で Subtask state を `in-review` に進めます。

## 典型的な流れ

直前の `/breakdown` や前回の `/develop` で `in-progress` になっている Subtask があります。`/develop #50` を実行する (もしくは `/develop` だけ実行して自動選択させる) と処理が始まります。

Dev agent は Subtask の AC を読み、`feat/50-email-form-integration` のようなブランチを切り、実装を書きます。途中で `feat(auth): add password reset form` / `test(auth): cover form validation cases` のような commit を重ねます。AC が満たされ、local の self-check が通ったら、`gh pr create --draft` を走らせ、本文に `Closes #50` を入れます。closing keyword は DoD で必須であり、merge 時に GitHub が Issue を自動 close します。続いて `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` を走らせ、CI が無事に起動したことを確認します。最後に Subtask を `in-review` に進めます。

コマンドの完了時には、draft PR の URL と「次は `/review <pr-url>` を実行してください」という案内が表示されます。ready への昇格は `/develop` の責務ではなく、Pass の verdict が出た後に `/review` が行います。

## 出力

- origin に push された新しいブランチ
- draft PR の URL
- DoD 自己チェックの結果
- Subtask state が `in-review` に進んだこと
- CI 起動の結果 (情報)

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — `/develop` は Dev agent の担当
- [PR ライフサイクル](/ja/concept/pr-lifecycle/) — PR が draft で始まる理由と、`/develop` が ready に昇格させない理由
- [DoD](/ja/policies/dod/) — draft を開く前に Dev が自己適用するチェックリスト
- 前: [`/breakdown`](/ja/commands/breakdown/) / 次: [`/review`](/ja/commands/review/)
- canonical な契約: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md)
