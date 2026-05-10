---
title: tracker operations
description: profile で名前空間化された operation skill (create-subtask, transition-state, set-sp, query-backlog, query-state, add-dependency, wait-for-pr-checks) の概要。
sidebar:
  order: 14
---

tracker operation は、soloscrum の command が profile 非依存に保たれることを可能にするレイヤーです。tracker に触れるすべての read または write は、`soloscrum-tracker-{profile}-{operation}` という名前の skill に委譲されます — profile は `github` または `linear`、operation は下の小さく固定された語彙から来ます。アクティブな profile を解決すること ([`define-tracker-profile`](/reference/define-tracker-profile/) に従う) は prefix を選ぶことと同じです。

## なぜ dispatcher ではなく名前空間化された skill なのか

フレームワークは意図的に、呼び出し時に profile を解決する汎用 dispatcher を **同梱しません**。代わりに、operation skill の *名前* が dispatch をエンコードします: `soloscrum-tracker-github-create-subtask` と `soloscrum-tracker-linear-create-subtask` は、2 つの異なるボディを持つ 2 つの異なる skill です。`github-only` を解決した agent は `github-` skill を直接呼びます; `linear-` skill は単に scope に入りません。

これにより各 operation の契約は狭く保たれ (両方の backend を 1 つのボディで扱う必要がない)、agent の allowed-tools リストは正直に保たれます (agent はアクティブな profile が実際に使うツールだけを宣言する)。

## operation 一覧

| Operation | github-only skill | linear+github skill | いつ発火するか |
|---|---|---|---|
| Create subtask | `soloscrum-tracker-github-create-subtask` | `soloscrum-tracker-linear-create-subtask` | `/breakdown` の register ステージ、提案された subtask ごとに 1 回 |
| Transition state | `soloscrum-tracker-github-transition-state` | `soloscrum-tracker-linear-transition-state` | `/develop` (`→ in-review`)、`/design-ui` (`→ in-review`)、`/review` (Pass で `→ done`、Fail で `→ in-progress`) |
| Set subtask SP | `soloscrum-tracker-github-set-sp` | `soloscrum-tracker-linear-set-sp` | subtask 作成時 (典型的にはインラインで)。後の編集のみ別呼び出し。 |
| Query backlog | `soloscrum-tracker-github-query-backlog` | `soloscrum-tracker-linear-query-backlog` | `/next` と `/status` で priority 順にグループ化された pending 作業をリストするとき |
| Query current state | `soloscrum-tracker-github-query-state` | `soloscrum-tracker-linear-query-state` | `/status` で in-progress / in-review 項目と PR / Figma リンクをリストするとき |
| Add dependency | `soloscrum-tracker-github-add-dependency` | `soloscrum-tracker-linear-add-dependency` | `/breakdown` で subtask 同士に peer-blocking 関係があるとき |
| Wait for PR checks | `soloscrum-tracker-github-wait-for-pr-checks` | (同じ skill — profile 非依存、PR は profile に関わらず GitHub 上にある) | `/develop` で `gh pr create --draft` の後 (CI 開始確認)、`/review` で Pass の後 (`gh pr ready` 前の CI green ゲート) |

operation セットは意図的に小さく、概念ごとに動詞 1 つ、加えて PR-CI 待機です。このリスト外のもの — Issue クローズ、PR merge — は、ユーザゲートか、GitHub 自身が処理するもの (例: `Closes #N` 経由の merge 時 auto-close) です。

## 特定 operation についての 2 つの注記

### `wait-for-pr-checks` は profile 非依存

`soloscrum-tracker-linear-wait-for-pr-checks` は存在しません。両 profile で PR は GitHub 上にあり、Linear は PR CI を管理しません。同じ skill (および `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh` のコロケートされたシェルスクリプト) が両 profile で使われます。

この skill が存在する理由は、インラインの `until ... gh pr view ... sleep ...` ループが anti-pattern だからです: PR 番号を command 文字列に埋め込むためハーネス allowlist マッチングを台無しにし、rollup 正規化の `jq` フィルタをセッションごとに再発明します。スクリプトが正本の実装です。

### `transition-state` は決して Issue をクローズしない

両 profile の `transition-state` skill は state 値を移動させますが、`gh issue close` を **決して** 呼びません。Issue クロージャは `gh pr merge` の下流 (PR 本文の `Closes #N` キーワード経由) か、GitHub が auto-close しなかった親 Issue については `/refine` の janitor sweep です。完全な根拠については [PR ライフサイクル](/concept/pr-lifecycle/) を参照。

## 関連項目

- なぜフレームワークが profile 非依存の core とこれらの profile 名前空間化された operation に分かれるのかについては、[tracker profile](/concept/tracker-profile/) を参照。
- 正本の operation skill は [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills) 配下にあります — `soloscrum-tracker-` で検索してください。
- wait-for-checks スクリプトの起動契約については [`skills/soloscrum-tracker-github-wait-for-pr-checks/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-tracker-github-wait-for-pr-checks/SKILL.md) を参照。
