---
title: /breakdown
description: size 閾値を超える Issue を type と SP 付きの Subtask に分割し、active tracker に登録する。
sidebar:
  order: 2
---

`/breakdown` は 2 番目のステップです。1 つの PR で着地するには大きすぎる Issue — size-check SP が 5 を超えるか、作業が明らかに複数の subsystem にまたがるか — を受け取り、それぞれが type 付き (`develop` または `design-ui`) で 1 つの PR が満たせるサイズに調整された Subtask のリストに変換します。Subtask は active tracker に書き込まれます。

## Usage

```bash
/breakdown <issue-url or issue-number>
```

引数は親 Issue です。URL 形式 (`https://github.com/<owner>/<repo>/issues/<n>`) でも生の番号 (`#48` または `48`) でも動きます。

## What happens

1. **Issue を読む。** Design agent が親 Issue の Background, Goal, AC, Out of Scope を読みます。
2. **分解を計画する。** Design は Subtask のリストを提案します: title、type (コードなら `develop`、Figma 作業なら `design-ui`)、各 Subtask の AC、Subtask 間の blocking 関係 (例: *Subtask B は Subtask A に依存*) があればそれも。
3. **Validate.** Design は提案された分割に対して size check を再実行します — どれかの Subtask がまだ大きすぎる、または分解が 5 個を超える場合、split test が再度発火し、提案が refine された slice として戻ってきます。
4. **Confirmation.** 分解提案がユーザに提示され、tracker write の前に承認が求められます。
5. **Registration.** 承認後、Dev agent が `soloscrum-tracker-{github|linear}-create-subtask` 経由で各 Subtask を tracker に書き込みます。subtask の SP は [story-points](/ja/policies/story-points/) スケールから、AC を慎重に読んだうえで Subtask ごとに適用されます。Subtask 間の依存は `soloscrum-tracker-{github|linear}-add-dependency` 経由で追加されます。

## Typical flow

`/refine` 中に *"add password reset flow"* という Issue を file し、`/refine` から size-check SP 8 — 大きすぎる — と告げられたとします。ユーザは親 Issue に対して `/breakdown 48` を再実行します。Design は 4 つの Subtask 提案で戻ってきます: password reset form の mockup の `design-ui` subtask、email 送信 backend の `develop` subtask、form 統合の `develop` subtask、rate-limit / abuse 対策の `develop` subtask。form を触る 2 つの `develop` subtask は `design-ui` subtask が review されることに依存します。

ユーザは承認します。Dev は親の下に 4 つの Subtask を書きます: GH Sub-issue (`github-only` の場合) または Linear subtask (`linear+github` の場合)。それぞれが SP、type label、AC、parent link を持ちます。form-integration subtask と design-ui subtask の依存は記録されます — `github-only` では body の `Depends on: #N` 行として、`linear+github` では Linear の "Blocked by" relation として。

分解結果が 1 つの Subtask だけで、その作業が 1 つの PR にきれいに収まる場合、`/breakdown` は不要です — `/refine` から直接 `/develop` に行けます。分割は PR-and-review 単位を verdict しやすい程度に小さく保つために存在します; すでに PR サイズの Issue で実行することは framework が強制するステップではありません。

## Output

- 提案された Subtask リスト (title, type, SP, dependencies) — 承認のために提示。
- 承認後: 作成された Subtask ID (`github-only` では `#N`、`linear+github` では `PRJ-N`)。
- 各 Subtask は type label (`type:develop` / `type:design-ui`) と parent-child link を持つ。

## See also

- [Agents and responsibilities](/ja/concept/agent-responsibilities/) — Design が分解を提案し、Dev が登録する。
- [Issue size](/ja/policies/issue-size/) — Issue が大きすぎて `suggest_split` が発火するとき。
- [Story points](/ja/policies/story-points/) — Subtask ごとに適用される SP スケール。
- [Tracker profile](/ja/concept/tracker-profile/) — Subtask レコードがどこに住むか。
- ライフサイクルの前: [`/refine`](/commands/refine/)。次: [`/develop`](/commands/develop/)。
- 正本の契約: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md)。
