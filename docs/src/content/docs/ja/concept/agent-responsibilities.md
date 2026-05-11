---
title: agent と責務
description: 5 つの soloscrum agent (PO / Design / Dev / UI / Review) が何を作り何を変更できるか、ライフサイクルでどう引き継がれるか。
sidebar:
  order: 2
---

soloscrum は 1 つの機能の作業を 5 つのロールに分け、それぞれを Claude Code agent が担当する。この分割は意図的なものだ。ボード上のすべての概念（Issue、subtask、PR、verdict）には creator が 1 ロールだけ存在し、ライフサイクル中に変更できる mutator も 1 ロールに限定されている。この single-creator ルールがあるからこそ、2 つの agent が同じ subtask を競って作ったり、ある agent が他の agent の所有する Issue を勝手に閉じたりといった事故が起きない。

このページは各 agent への人間向け導入だ。正本のオーナーシップ行列は [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md) を参照のこと。

## 5 つの agent

### `soloscrum-po` — Product Owner

PO はエントリポイントだ。`/refine` の中で動き、自由形式のアイデアを構造化された GitHub Issue に変換する: 動詞で始まるタイトル、Background、Goal、Acceptance Criteria、そして明示的な Out of Scope。Issue レベルの priority と size-check SP — Issue がそのままライフサイクルに乗せられるサイズか、先に分割すべきかを判断するためのざっくり見積もり — を割り当てるのも PO だ。

親 Issue のメタデータを作成後に変更できるのも PO だけだ。さらに `/refine` の janitor sweep も担当する。これは、クロージング PR が親ではなく sub-issue を参照したことで GitHub が auto-close しなかった親 Issue を、後追いで閉じるクリーンアップパスだ。

### `soloscrum-design` — Designer

Design agent は `/validate` と `/breakdown` のプランニング段階で動く。validate 済みの Issue を実装可能なプランに落とすのが仕事だ: scope、依存関係、技術的なフィージビリティを確認し、type と AC を揃えた subtask 案を提案する。tracker への subtask 登録は **行わない** — そこは Dev の仕事だ。

「breakdown を設計した」ことと「subtask を登録した」ことを分けてあるおかげで、design のパスは tracker 書き込みを伴わない冪等な思考ステップとして扱える。tracker への書き込みは最後にまとめて発生する。

### `soloscrum-dev` — Developer

Dev は実装そのものを担当する。動く場所は 2 か所だ。1 つは `/breakdown` の登録段階で、Design が提案した subtask を SP / type ラベル / 親リンクとともに tracker に書き込む。もう 1 つは `/develop` で、branch を切り、コードを書き、Conventional Commits で commit し、draft PR を開く。

subtask を idle から `in-progress` へ、そして draft PR を開いた後に `in-progress` から `in-review` へ遷移させるのも Dev の役割だ。

### `soloscrum-ui` — UI Designer

UI agent は Dev の design-ui 版に当たる。`/design-ui` の中で動き、`type:design-ui` がタグ付けされた subtask に対して Figma 成果物 — コンポーネント、design token、状態バリアント、accessibility チェック — を作る。Dev と同様、Figma ファイルが揃った時点で自分の subtask を `in-review` に遷移させる。

UI を伴う機能は `design-ui` subtask と後続の `develop` subtask に分割される。`develop` 側の作業は、design subtask の review が通るまで待機する。

### `soloscrum-review` — Reviewer

何かを done としてマークできるのは Review だけだ。`/review` の中で動き、DoD と AC を検証し、CodeRabbit + multi-agent review pipeline を走らせ、各 finding を個別に決定し、verdict コメントを投稿する。Pass なら subtask を `done` に遷移させ、CI が green になるのを待ち、PR を draft から ready に昇格させる。最後の `gh pr merge` は常にユーザのゲートで、agent は「これが merge command です」と提示して止まる。

ボード上の他の概念の verifier も Review だ。state を terminal な状態に切り替える必要がある場面では、切り替えるのは必ず Review になる。

## ライフサイクルの全体像

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → Issue を読み、無効なら refine を要求
/breakdown     design   → subtask を提案 (type, AC)
               dev      → subtask を登録 (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + token + state; subtask → in-review
/review        review   → DoD + AC + コード; PR を ready に昇格;
                          subtask → done; merge command をユーザに提示
user           user     → `gh pr merge` を実行 (irreversible, ユーザゲート)
/refine        po       → janitor が GH の取りこぼした親 Issue をクローズ
```

## single-creator ルール

全体を貫く 3 つのルールがある。どの soloscrum command を読むときも頭に置いておく価値がある:

1. **概念ごとに creator は 1 ロール。** 同じ種類のレコードを 2 つのロールが作ることはない。Issue は PO、subtask レコードは Dev、PR / Figma 成果物は Dev または UI。同じ AC に対して 2 つの agent が重複 subtask を file する経路は存在しない。
2. **state 遷移はロールゲート。** 任意のレコードを terminal state に遷移させられるのは Review だけだ。Dev と UI は自分の subtask を `in-review` まで動かせるが、`done` に動かせるのは Review しかいない。
3. **verifier は常に Review。** 例外は entry-gate の SP（PO）と type ラベル（Dev / UI）だが、これらは検証ではなく決定にあたる。

## 関連項目

- 完全なオーナーシップ行列は [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md) を参照。
- PR の遷移が reversible (agent 実行) と irreversible (ユーザゲート) にどう分かれるかは、[PR ライフサイクル概念](/ja/concept/pr-lifecycle/) を参照。
