---
title: agent と責務
description: 5 つの soloscrum agent (PO, Design, Dev, UI, Review) と、それぞれが何を作成・変更するか、ライフサイクル中にどうハンドオフされるか。
sidebar:
  order: 2
---

soloscrum は 1 つの機能の作業を 5 つのロールに分割し、それぞれを Claude Code agent が担当します。この分割は意図的です: ボード上のすべての概念（Issue、subtask、PR、verdict）には、creator が 1 ロール、ライフサイクル中に変更を許可される mutator が 1 ロールだけ存在します。この single-creator ルールが、2 つの agent が同じ subtask を競って作成したり、ある agent が他の agent が所有する Issue を静かにクローズしたりする事態を防ぎます。

このページは各 agent への人間向けの導入です。正本のオーナーシップ行列は [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md) にあります。

## 5 つの agent

### `soloscrum-po` — Product Owner

PO はエントリポイントです。`/refine` 中に動作し、自由形式のアイデアを構造化された GitHub Issue に変換します: 動詞で始まるタイトル、Background、Goal、Acceptance Criteria、明示的な Out of Scope。Issue レベルの priority と size-check SP — Issue がライフサイクルに入れるほど小さいか、それとも先に分割が必要かを判断するための rough な見積もり — を割り当てるロールでもあります。

PO は親 Issue のメタデータが存在した後にそれを変更できる唯一のロールであり、`/refine` の janitor sweep — クロージング PR が親ではなく sub-issue を参照したために GitHub が auto-close しなかった親 Issue を閉じるクリーンアップパス — を実行するロールでもあります。

### `soloscrum-design` — Designer

Design agent は `/validate` および `/breakdown` の planning ステージ中に動作します。その仕事は、validate 済みの Issue を実装可能なプランに変換することです: scope、依存関係、技術的フィージビリティを確認し、registration 用に type と AC が揃った subtask のリストを提案します。tracker 上に subtask レコードを **作成** することはしません — その手順は Dev に属します。

「breakdown を設計した」ことと「subtask を登録した」ことの分離が、design パスを冪等な thinking ステップとして扱い、tracker 書き込みを最後にバッチでまとめておくことを可能にしています。

### `soloscrum-dev` — Developer

Dev は実際の実装を所有します。2 か所で動作します: `/breakdown` の registration ステージで Design が提案した subtask を tracker に書き込み（SP、type ラベル、親リンクとともに）、`/develop` で branch を切り、コードを書き、Conventional Commits で commit し、draft PR を開きます。

Dev は、subtask を idle から `in-progress` へ、そして draft PR が開いた後に `in-progress` から `in-review` へ遷移させるロールでもあります。

### `soloscrum-ui` — UI Designer

UI agent は Dev の design-ui 版です。`/design-ui` 中に動作し、`type:design-ui` がタグ付けされた subtask に対して Figma 成果物 — component、design token、状態バリアント、accessibility チェック — を生成します。Dev と同じく、Figma ファイルが完成した時点で自分の subtask を `in-review` に遷移させるロールです。

UI 機能は `design-ui` subtask とそれに続く `develop` subtask に分割されます; `develop` 作業は design subtask が review されるまで待ちます。

### `soloscrum-review` — Reviewer

Review は何かを done としてマークできる唯一のロールです。`/review` 中に動作します: DoD と AC を検証し、CodeRabbit + multi-agent review pipeline を実行し、各 finding を個別に決定し、verdict コメントを投稿します。Pass の場合、subtask を `done` に遷移させ、CI が green になるのを待ち、PR を draft から ready に昇格させます。実際の `gh pr merge` は常にユーザのゲートです — agent は「これが merge command です」で停止します。

Review はボード上のあらゆる他の概念の verifier でもあります。state を terminal status に切り替える必要があるとき、それを切り替えるのは Review です。

## ライフサイクルの俯瞰

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

これらをまとめる 3 つのルールは、どの soloscrum command を読むときにも頭に入れておく価値があります:

1. **概念ごとに creator は 1 つ。** 2 つのロールが同じ種類のレコードを作ることはありません。PO が Issue を作成し、Dev が subtask レコードを作成し、Dev または UI が PR / Figma 成果物を作成します。同じ AC に対して 2 つの agent が重複した subtask を file するパスは存在しません。
2. **state 遷移はロールゲート。** Review のみが任意のレコードを terminal state に遷移できます。Dev と UI は自分の subtask を `in-review` に動かせますが、`done` に動かせるのは Review だけです。
3. **verifier は常に Review** — 例外は entry-gate SP (PO) と type ラベル (Dev / UI) で、これらは検証ではなく決定です。

## 関連項目

- 完全なオーナーシップ行列は [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md) を参照。
- 簡潔な spec サマリは [agent responsibilities リファレンス](/reference/define-agent-responsibilities/) を参照。
- PR 遷移が reversible (agent が実行) と irreversible (ユーザがゲート) にどう分かれるかは、[PR ライフサイクル概念](/concept/pr-lifecycle/) を参照。
