---
title: "/soloscrum:develop"
description: develop の work unit（Subtask または Sub-issue を持たない Issue）を実装します。リポジトリ内に専用の git worktree を作り、そこでコードを書き、draft PR を開き、ターゲットを in-review に進めます。
sidebar:
  order: 3
---

`/soloscrum:develop` は `type:develop` の work unit を実装します — 親が `/soloscrum:breakdown` を通った **Subtask** か、Issue の intent が 1 つの reviewable PR に収まり [issue size](/ja/policies/issue-size/) によって `/soloscrum:breakdown` をスキップした **no-Subtask Issue** のいずれかです。soloscrum の命名規約でブランチを作り、**そのブランチ専用の git worktree** をリポジトリ内に用意して実装を書き、[DoD](/ja/policies/dod/) を自己チェックし、**draft** PR を開きます。draft が開いた時点で、ターゲット（Subtask または no-Subtask Issue）の state は `in-progress` から `in-review` に進みます。

## 使い方

```bash
/soloscrum:develop <subtask-id-or-issue-id>
```

引数は Subtask の URL または ID、**または** no-Subtask Issue の URL または ID (`github-only` なら `#N`、`linear+github` なら `PRJ-N`) です。どちらのケースかは、参照される Issue が親の下にある Subtask か、Sub-issue を持たない単独 Issue かで決まります（[branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の契約を参照）。省略すると、active tracker の query skill で `in-progress` の work unit を自動選択します。

## 処理の流れ

1. **ターゲットを読む。** Subtask ターゲットの場合、Dev agent は Subtask の "what" + Checklist（[issue format](/ja/policies/issue-format/) の Subtask 本文に従ったスライススコープ）と**親 Issue の AC** を読みます。no-Subtask Issue ターゲットの場合は Issue の AC を直接読みます。加えて `.claude/rules/*.md` 配下のオーバーライド (stack / branch 戦略 / DoD の追加項目) を読みます。
2. **worktree とブランチを作る。** [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の規約に従い、`<type>/<issue-id>-<slug>` 形式でブランチを作ります — Subtask ターゲットなら `feat/123-password-reset`、no-Subtask Issue ターゲットなら `refactor/456-cleanup-legacy-router` のような形。そのブランチはリポジトリ内の `<worktree_root>/<branch>/` に**専用の git worktree** として check out されます（`worktree_root` の既定値は `.soloscrum/worktrees` で、`.claude/rules/branch.md` でリポジトリごとに変更できます）。メインのチェックアウトはデフォルトブランチのまま clean に保たれ、2 つの work unit が同時に進行してもぶつかりません。新しい worktree を作る前に、すでにマージ済みのブランチの worktree は回収されます（[`/soloscrum:cleanup`](/ja/commands/cleanup/) と同じ処理）。
3. **実装する。** Conventional Commits (`feat: …` / `fix: …` / `refactor: …`) で commit を重ねます。
4. **DoD 自己チェック。** Dev が担当できる DoD 項目をすべて確認します — AC を適切なレイヤーで検証（Subtask PR ならスライス配信 + 親 AC への退行なし、no-Subtask Issue PR なら Issue 全 AC、[DoD](/ja/policies/dod/) 参照）、必要な箇所にテストがある、lint がクリーン、PR 本文に closing keyword が入る予定（Subtask ターゲットなら `Closes #<subtask>`、no-Subtask Issue ターゲットなら `Closes #<issue>` — branch-commit の parent-close 契約により、Subtask PR で `Closes #<parent>` は書かない）。「review が pass している」だけは Dev が自分で出せず、`/soloscrum:review` の担当です。
5. **draft で PR を開く。** `gh pr create --draft` がここの境界です。GitHub 側 reviewer が動く前に local の quality gate を回す窓を確保するため、PR は常に draft で始まります ([PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照)。
6. **CI が起動したことを確認する。** wait-for-checks スクリプトを短いタイムアウト (例: 300 秒) で走らせます。狙いは「CI 起動時の失敗 (workflow syntax error、secret 不足など) をこの段階で表面化させ、`/soloscrum:review` で初めて気付く事態を避ける」ことです。green を待つことではありません。
7. **state を進める。** active tracker の transition skill でターゲット（Subtask または no-Subtask Issue）の state を `in-review` に進めます。

## 典型的な流れ

**Subtask ターゲット。** 直前の `/soloscrum:breakdown` や前回の `/soloscrum:develop` で `in-progress` になっている Subtask があります。`/soloscrum:develop #50` を実行する (もしくは `/soloscrum:develop` だけ実行して自動選択させる) と処理が始まります。

Dev agent は Subtask のスライススコープ（"what" + Checklist）と親 Issue の AC を読み、`feat/50-email-form-integration` のようなブランチを切り、実装を書きます。途中で `feat(auth): add password reset form` / `test(auth): cover form validation cases` のような commit を重ねます。スライスが配信され（親 AC に退行なし）、local の self-check が通ったら、`gh pr create --draft` を走らせ、本文に `Closes #50` を入れます — Subtask 番号であって、**親 Issue 番号は決して書きません**（[branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) の parent-close 契約に従う）。続いて `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` を走らせ、CI が無事に起動したことを確認します。最後に Subtask を `in-review` に進めます。

**no-Subtask Issue ターゲット。** Issue の intent が 1 つの reviewable PR に収まる場合（小さなバグ修正、self-contained なリファクタリングなど）、`/soloscrum:breakdown` をスキップして Issue に直接 `/soloscrum:develop` を実行します（例: `/soloscrum:develop #456`）。流れは同じ形 — ブランチは `refactor/456-cleanup-legacy-router`、PR 本文は `Closes #456`（Issue 本体）、state 遷移も Issue 上で。DoD の「Subtask を持たない Issue」経路が適用され、`/soloscrum:review` は Issue の**全**AC を PR に対して検証します。

コマンドの完了時には、draft PR の URL と「次は `/soloscrum:review <pr-url>` を実行してください」という案内が表示されます。ready への昇格は `/soloscrum:develop` の責務ではなく、Pass の verdict が出た後に `/soloscrum:review` が行います。

## 出力

- origin に push された新しいブランチ（worktree root 配下の専用 worktree に check out 済み）
- draft PR の URL
- DoD 自己チェックの結果
- ターゲット（Subtask または no-Subtask Issue）の state が `in-review` に進んだこと
- CI 起動の結果 (情報)

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — `/soloscrum:develop` は Dev agent の担当
- [PR ライフサイクル](/ja/concept/pr-lifecycle/) — PR が draft で始まる理由と、`/soloscrum:develop` が ready に昇格させない理由
- [DoD](/ja/policies/dod/) — draft を開く前に Dev が自己適用するチェックリスト
- [`/soloscrum:cleanup`](/ja/commands/cleanup/) — PR がマージされたあとに worktree を回収する
- 前: [`/soloscrum:breakdown`](/ja/commands/breakdown/) / 次: [`/soloscrum:review`](/ja/commands/review/)
- canonical な契約: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md)
