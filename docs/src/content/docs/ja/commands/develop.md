---
title: /develop
description: develop Subtask を実装する。branch を切り、コードを書き、draft PR を開き、Subtask を in-review に遷移させる。
sidebar:
  order: 3
---

`/develop` はコードを書く場所だ。`type:develop` の Subtask を受け取り、soloscrum の命名規約に従って branch を切り、実装を書き、[DoD](/ja/policies/dod/) の self-check を回し、**draft** PR を開く。draft が開いた時点で Subtask は `in-progress` から `in-review` に遷移する。

## Usage

```bash
/develop <subtask-id>
```

引数は Subtask の URL または ID で、`github-only` なら `#N`、`linear+github` なら `PRJ-N` の形だ。引数を省略した場合、active tracker の query skill 経由で `in-progress` の Subtask を自動選択する。

## 何が起きるか

1. **Subtask を読む.** Dev agent が Subtask AC・親 Issue・`.claude/rules/*.md` の override (stack / branch 戦略 / DoD extras) を読む。
2. **branch を切る.** [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) 規約に従って新しい branch を作る: `<type>/<issue-id>-<slug>` (例: `feat/123-password-reset`)。
3. **実装する.** Conventional Commits (`feat: …`、`fix: …`、`refactor: …`) の形でコードを着地させる。
4. **DoD self-check.** Dev が自分の所有する DoD 項目をすべて検証する: AC が満たされていること、該当する場合のテスト、lint clean、PR 本文に Issue の closing keyword が含まれること。「Review has passed」だけは Dev が self-grant できない項目で、これは `/review` の担当だ。
5. **draft で PR を開く.** `gh pr create --draft` がここでの境界線になる。soloscrum では PR は常に draft で始まる — GitHub 側の reviewer が動き出す前に、決められた window の中でローカルの quality gate を走らせるためだ (理由は [PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照)。
6. **CI が起動したか確認する.** 続けて短い timeout (例えば 300 秒) で wait-for-checks スクリプトを走らせる。これは green ゲートではなく、CI 起動の失敗 (workflow ファイルの構文エラーや欠けている secret) を、`/review` が後で発見するより前にこのステップで surface するためのものだ。
7. **state 遷移.** Subtask の state を、active tracker の transition skill 経由で `in-review` に動かす。

## 典型的な流れ

スタート地点は `in-progress` の Subtask だ。たいていは親 Issue に対して `/breakdown` を走らせて Dev が tracker に書き込んだ状態か、以前 `/develop` を実行して state を設定した状態にある。`/develop #50` を実行する (`/develop` だけにすれば、open な `in-progress` Subtask を自動的に拾う)。

Dev agent は Subtask AC を読み、`feat/50-email-form-integration` のような branch を開き、関連ファイルにまたがって実装を書く。進めながら commit を切る (`feat(auth): add password reset form`、`test(auth): cover form validation cases` といった具合だ)。AC を満たしてローカル self-check が pass したら、`Closes #50` を含む本文を付けて `gh pr create --draft` を実行する (closing keyword は、merge 時に GitHub が Issue を自動でクローズするように DoD で求めている)。続いて `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` を走らせ、CI が clean に立ち上がったかを確認する。最後に Subtask を `in-review` に動かす。

ユーザへの handoff は、draft PR の URL と「次に `/review <pr-url>` を実行する」という推奨だ。ready への昇格は `/develop` の役割では **ない** — それは Pass verdict が出た後の `/review` の担当だ。draft で止まるのはライフサイクルの設計上の意図であって、ユーザの追加指示を待つためではない。

## Output

- 新しい branch が origin に push される。
- draft PR の URL。
- DoD self-check の結果。
- Subtask state が `in-review` に進む。
- CI 起動の結果 (informational)。

## 関連項目

- [agent と責務](/ja/concept/agent-responsibilities/) — `/develop` は Dev が所有する。
- [PR ライフサイクル](/ja/concept/pr-lifecycle/) — PR を draft で始める理由と、`/develop` が ready に昇格させない理由。
- [DoD](/ja/policies/dod/) — draft を開く前に Dev が self-apply するチェックリスト。
- ライフサイクルの前のステップ: [`/breakdown`](/ja/commands/breakdown/)。次のステップ: [`/review`](/ja/commands/review/)。
- 正本の契約: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md)。
