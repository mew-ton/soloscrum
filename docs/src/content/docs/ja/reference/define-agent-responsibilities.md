---
title: define-agent-responsibilities
description: spec サマリ — soloscrum の各概念を、ライフサイクルを通じて誰が作成・変更・検証するか。
sidebar:
  order: 1
---

`soloscrum-define-agent-responsibilities` は、soloscrum ボード上のすべての概念 (Issue、subtask、branch、PR、Figma 成果物、コード、DoD self-check、各種ラベルや state 値) を、ちょうど 1 つの Creator と正規の Mutator の集合に結びつけるオーナーシップ行列です。すべての command と agent はこの skill を参照として宣言し、自分が所有しないカラムへの書き込みを拒否します。

## 何をするか

race と silent overlap を防ぐ 3 つのルールを固定します:

1. 概念ごとに Creator は 1 つ — 2 つのロールが同じ種類のレコードを作ることはありません。
2. state 遷移はロールゲート — `soloscrum-review` のみが任意のレコードを terminal state (Done / Closed) に遷移できます。
3. verifier は常に Review — 例外は entry-gate SP (PO) と type ラベル (Dev / UI) で、これらは検証ではなく決定です。

行列は profile 非依存です。概念とオーナーシップは、データの保存場所に関わらず同じです; storage 場所は [`define-tracker-profile`](/reference/define-tracker-profile/) に委譲されます。

## いつ消費されるか

すべての soloscrum agent (`soloscrum-po`, `soloscrum-design`, `soloscrum-dev`, `soloscrum-ui`, `soloscrum-review`) は frontmatter でこの skill を宣言します。command は agent に委譲することで暗黙的にこれを参照します。

## 主要な入力と出力

skill 自体は出力を生成しません — リファレンスです。その内容は、各概念を次のものにマッピングする静的な行列です:

- Creator (最初に書き込むロール)
- Mutator (ライフサイクル中に正当に変更するロール)
- Verifier (close 前に確認するロール)

この行列の 1 行が、agent が write を提案する前にチェックするものです。行に他の agent がそのフィールドを所有すると書かれていれば、現在の agent は値を読みますが書きません。

## ライフサイクルサマリ

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → Issue を読み、無効なら refine を要求
/breakdown     design   → subtask を提案 (type, AC)
               dev      → subtask を登録 (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + token + state; subtask → in-review
/review        review   → DoD + AC + コード; PR を ready に昇格;
                          subtask → done; merge command をユーザに提示
user           user     → `gh pr merge` を実行
```

## 関連項目

- 人間向けのウォークスルーは [agent と責務](/concept/agent-responsibilities/) を参照。
- 正本の契約: [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md)。
- リポジトリローカルな override は `.claude/rules/agent-overrides.md` に書きます。
