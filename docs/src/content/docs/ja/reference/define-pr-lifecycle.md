---
title: define-pr-lifecycle
description: spec サマリ — PR フェーズ、reversible vs irreversible 遷移、ユーザ merge ゲート。
sidebar:
  order: 8
---

`soloscrum-define-pr-lifecycle` は、PR まわりすべてに対する autonomy 契約です。agent が確認なしに実行する遷移と、ユーザがゲートとなる遷移を確立します。

## 何をするか

3 つのルールを固定します:

1. **reversible な遷移は自律的。** `gh pr create --draft`, `gh pr ready`, `gh pr review --approve`, `gh pr comment`, ラベル編集, tracker state 遷移 — 実行し、報告。事前確認不要。
2. **irreversible な遷移はユーザゲート。** `gh pr merge`, 共有 branch への force-push, branch 削除。agent は正確な command を提示して停止する。
3. **verdict が決定点。** `/review` が verdict を生成したら、verdict 後シーケンスはそれ以上のプロンプトなしに end-to-end で実行される。

4 つのライフサイクルフェーズ — `draft`, `review`, `ready`, `merge-handoff` — と各ロールの所有者、draft window の根拠、solo-dev での self-approve refusal 処理、そして **Issue クローズは merge 時に発生する** (verdict 時ではない) というルールも固定します。

## いつ消費されるか

PR まわりの何かを行うすべての command と skill:

- `soloscrum-implement-task` は PR が draft で作成されるルールを読みます。
- `soloscrum-review-implementation` は verdict-to-action マッピングと self-approve fallback を読みます。
- tracker `transition-state` skill は agent autonomy 契約のためにこれを参照します。

## 主要な入力と出力

入力は: 現在の PR フェーズ、verdict (該当時)、稼働中の tracker profile (state-transition ステップのルーティングのみ)。出力は次に何を実行するかと事前確認するかどうかの判断です。skill 自体には副作用はありません; ルールブックです。

## verdict から次アクションへ

| Verdict | シーケンス | ユーザの事前確認? |
|---|---|---|
| Pass | approve → subtask `→ done` → CI green を待つ → `gh pr ready` → merge command を提示 | 不要 |
| Pass with follow-ups | follow-up Issue を確認 → Pass と同じ | 不要 |
| Fail | フィードバックを投稿 → subtask `→ in-progress` → PR を draft のまま | 不要 |
| → merge | ユーザが `gh pr merge` を実行 | **要** |

待機ステップ中の CI red は Pass を遡及的に Fail に降格します。

## この skill が防ぐ anti-pattern

- reversible な verdict 後ステップでの再プロンプト (「`gh pr ready` を実行してもよいですか?」)。
- verdict が Pass だったから `gh pr merge` を自律的に実行する。
- self-approve refusal を Fail として扱う。
- verdict 後シーケンスの一部として親 Issue をクローズする (クローズは merge 時に発生する)。

## 関連項目

- 人間向けのウォークスルーは [PR ライフサイクル](/concept/pr-lifecycle/) を参照。
- 正本の契約: [`skills/soloscrum-define-pr-lifecycle/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-pr-lifecycle/SKILL.md)。
- finding がこのライフサイクルを駆動する verdict にどう変換されるかについては、[`define-code-review-process`](/reference/define-code-review-process/) を参照。
