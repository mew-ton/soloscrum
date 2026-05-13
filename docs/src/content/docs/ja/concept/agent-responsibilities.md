---
title: agent と責務
description: 5 つの soloscrum agent (PO / Design / Dev / UI / Review) の役割と、何を作れて何を変更できるか、どのようにライフサイクルで引き継がれるかを説明します。
sidebar:
  order: 2
---

soloscrum は機能の実装作業を 5 つの役割に分割し、それぞれを Claude Code agent が担当します。ボード上のすべての概念 — Issue / subtask / PR / verdict — について、作成できる役割は 1 つ、ライフサイクル中に変更できる役割も 1 つに限定されています。このルールにより、2 つの agent が同じ subtask を並行して作成したり、別の agent が所有する Issue を勝手に閉じたりすることを防げます。

責務マトリクスの canonical な定義は [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md) にあります。

## 5 つの agent

### `soloscrum-po` — Product Owner

PO はライフサイクルの入口です。`/refine` で動作し、形のないアイデアを GitHub Issue に整形します。動詞から始まるタイトル、Background、Goal、Acceptance Criteria、Out of Scope の 4 セクションで構成された Issue を作成し、priority と size-check 用の SP もここで付与します。size-check SP は、その Issue がライフサイクルに進めるサイズか、先に分割すべきかを判定するための概算値です。

親 Issue のメタデータを後から変更できるのは PO だけです。`/refine` の janitor sweep — closing PR が sub-issue 側を参照していたために GitHub が自動 close できなかった親 Issue を回収する処理 — も PO の担当です。

### `soloscrum-design` — Designer

Design は `/validate` と `/breakdown` の計画フェーズで動作します。validate 済みの Issue を、実装可能な計画に落とし込みます。スコープ、依存関係、技術的な実現性を確認し、type と AC を持つ subtask のリストを作って登録に渡します。

Design は **subtask レコードをトラッカーに書き込みません**。書き込みは Dev の仕事です。Design パスを冪等な思考ステップに保ち、トラッカーへの書き込みは最後にまとめて行う、という分業になっています。

### `soloscrum-dev` — Developer

Dev は実装を担当します。動作する場面は 2 つです。

- **`/breakdown` の registration ステージ** — Design が提案した subtask をトラッカーに書き込みます (SP / type ラベル / 親リンク)。
- **`/develop`** — ブランチを切り、コードを書き、Conventional Commits で commit し、draft PR を開きます。

subtask の state を idle から `in-progress` に進めるのも、draft PR を開いた後に `in-progress` から `in-review` に進めるのも Dev です。

### `soloscrum-ui` — UI Designer

UI は design-ui 領域における Dev の対になる役割です。`/design-ui` で動作し、`type:design-ui` がついた subtask に対して Figma 上の成果物 — component、design token、state variant、accessibility check — を作ります。Dev と同様に、Figma ファイルが完成した時点で自分の subtask を `in-review` に進めます。

UI 関連の機能は通常、`design-ui` subtask と、その後に続く `develop` subtask に分けて扱います。`develop` 側は design 側の review が終わるまで待機します。

### `soloscrum-review` — Reviewer

Review は唯一、何かを done にできる役割です。`/review` で動作し、DoD と AC を検証し、CodeRabbit + multi-agent の review pipeline を走らせ、見つかった finding を 1 件ずつ判断し、verdict コメントを投稿します。Pass の場合は subtask を `done` に進め、CI green を待ち、PR を draft から ready に昇格させます。`gh pr merge` だけは常にユーザのゲートで、agent は merge コマンドを提示した時点で停止します。

ボード上の他の概念についても、verifier は常に Review です。terminal な状態へ進められるのは Review だけです。

## ライフサイクル概観

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (type, AC)
               dev      → registers subtasks (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + tokens + states; subtask → in-review
/review        review   → DoD + AC + code; promote PR to ready;
                          subtask → done; surface merge command to user
user           user     → runs `gh pr merge` (irreversible, user-gated)
/refine        po       → janitor closes any parent Issues GH missed
```

## 全体を支える 3 つのルール

1. **概念ごとに作成できる役割は 1 つだけ。** 同じ種類のレコードを 2 つの役割が作ることはありません。Issue を作るのは PO。subtask レコードを作るのは Dev。PR や Figma 成果物を作るのは Dev または UI。同じ AC に対して別々の agent が重複した subtask を起票する経路は存在しません。
2. **state 遷移は役割でゲートされる。** terminal な状態に遷移させられるのは Review だけです。Dev と UI は自分の subtask を `in-review` まで動かせますが、`done` に進められるのは Review に限られます。
3. **verifier は常に Review。** ただし入口の size-check SP は PO の判断、type ラベルは Dev または UI の判断です。

## 参考

- 完全な責務マトリクス: [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md)
- PR 遷移のうち agent が自律実行するものとユーザがゲートするものの線引き: [PR lifecycle](/ja/concept/pr-lifecycle/)
