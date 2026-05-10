---
title: /develop
description: develop Subtask を実装する。branch を切り、コードを書き、draft PR を開き、Subtask を in-review に遷移させる。
sidebar:
  order: 3
---

`/develop` はコードが書かれる場所です。`type:develop` の Subtask を受け取り、soloscrum の命名規約に従って branch を切り、実装を書き、[DoD](/ja/policies/dod/) の self-check を走らせ、**draft** PR を開きます。draft が開いた時点で Subtask は `in-progress` から `in-review` に遷移します。

## Usage

```bash
/develop <subtask-id>
```

引数は Subtask URL または ID (`github-only` では `#N`、`linear+github` では `PRJ-N`) です。省略した場合、active tracker の query skill 経由で `in-progress` の Subtask が自動選択されます。

## What happens

1. **Subtask を読む。** Dev agent が Subtask AC、親 Issue、stack / branch 戦略 / DoD extras に対する `.claude/rules/*.md` 上書きを読みます。
2. **Branch を切る。** [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) 規約に従って新しい branch が作成されます: `<type>/<issue-id>-<slug>` (例: `feat/123-password-reset`)。
3. **Implement.** コードは Conventional Commits (`feat: …`, `fix: …`, `refactor: …`) として着地します。
4. **DoD self-check.** Dev は所有するすべての DoD 項目を verify します: AC 充足、該当する場合のテスト、lint clean、PR 本文に Issue closing keyword が含まれること。"Review has passed" 項目は Dev が self-grant できない唯一の項目です — それは `/review` に属します。
5. **Draft で PR を開く。** `gh pr create --draft` が境界線です。soloscrum では PR は常に draft で始まります — GitHub 側 reviewer が発火する前に、定義された window 内で local quality gate が走るためです (なぜかは [PR lifecycle](/ja/concept/pr-lifecycle/) を参照)。
6. **CI 起動を確認する。** `/develop` は次に短い timeout (例: 300 秒) で wait-for-checks スクリプトを走らせます — green-gate ではなく、CI 起動失敗 (workflow ファイルの構文エラー、欠けている secret) を `/review` が後で発見する前にこのステップで surface するためです。
7. **State 遷移。** Subtask の state は active tracker の transition skill 経由で `in-review` に動きます。

## Typical flow

`in-progress` の Subtask から始まります — 普通は親で `/breakdown` を実行して Dev が tracker に書いたから、または以前 `/develop` を実行して state が設定されたからです。`/develop #50` を実行 (または `/develop` だけで、open な `in-progress` Subtask を自動 pick させる)。

Dev agent は Subtask AC を読み、`feat/50-email-form-integration` のような branch を開き、関連ファイルにまたがって実装を書き、進めながら commit します (`feat(auth): add password reset form`, `test(auth): cover form validation cases`)。AC が満たされ local self-check が pass したら、`Closes #50` を含む本文 (closing keyword は merge 時に GitHub が Issue を自動クローズするように DoD で要求されます) で `gh pr create --draft` を実行します。次に `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` を実行し、CI が clean に起動したかを確認します。Subtask は `in-review` に動かされます。

ユーザへの handoff は draft PR URL と、次に `/review <pr-url>` を実行するための推奨です。ready への昇格は `/develop` の一部では **ありません** — それは Pass verdict 後の `/review` が所有します。draft PR で停止することはライフサイクルの設計点であり、ユーザの追加指示を待つ場所ではありません。

## Output

- 新しい branch が origin に push される。
- Draft PR URL。
- DoD self-check の結果。
- Subtask state が `in-review` に進む。
- CI 起動結果 (informational)。

## See also

- [Agents and responsibilities](/ja/concept/agent-responsibilities/) — Dev がこの command を所有。
- [PR lifecycle](/ja/concept/pr-lifecycle/) — なぜ PR は draft で始まり、なぜ `/develop` が ready に昇格しないか。
- [DoD](/ja/policies/dod/) — Dev が draft を開く前に self-apply するチェックリスト。
- ライフサイクルの前: [`/breakdown`](/commands/breakdown/)。次: [`/review`](/commands/review/)。
- 正本の契約: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md)。
