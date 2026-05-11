---
title: /breakdown
description: size 閾値を超える Issue を、type と SP を付けた Subtask に分割し、active tracker に登録する。
sidebar:
  order: 2
---

`/breakdown` はライフサイクルの 2 番目のステップだ。size-check SP が 5 を超えていたり、作業が明らかに複数の subsystem にまたがっていたりする Issue は、1 つの PR で着地させるには大きすぎる。`/breakdown` はそうした Issue を受け取り、各 Subtask に type (`develop` または `design-ui`) を付け、1 つの PR が満たせるサイズに調整した Subtask 一覧に変換する。出来上がった Subtask は active tracker に書き込まれる。

## Usage

```bash
/breakdown <issue-url or issue-number>
```

引数は親 Issue だ。URL 形式 (`https://github.com/<owner>/<repo>/issues/<n>`) でも、`#48` や `48` のような生の番号でも動く。

## 何が起きるか

1. **Issue を読む.** Design agent が親 Issue の Background、Goal、AC、Out of Scope を読む。
2. **分解を計画する.** Design は Subtask のリストを提案する: title、type (コードなら `develop`、Figma 作業なら `design-ui`)、Subtask ごとの AC、そして Subtask 間に blocking 関係 (例: *Subtask B は Subtask A に依存*) があればそれも含めて提示する。
3. **検証.** Design は提案した分割に対して size check を再実行する。どれかの Subtask がまだ大きすぎたり、分解が 5 個を超えたりすると、split test が再度発火し、提案が refine された slice として戻ってくる。
4. **承認待ち.** 分解提案をユーザに見せ、tracker への書き込み前に承認を待つ。
5. **登録.** 承認されると、Dev agent が `soloscrum-tracker-{github|linear}-create-subtask` 経由で各 Subtask を tracker に書き込む。Subtask の SP は [story-points](/ja/policies/story-points/) スケールから、AC を読んだうえで Subtask ごとに適用する。Subtask 間の依存は `soloscrum-tracker-{github|linear}-add-dependency` で記録する。

## 典型的な流れ

`/refine` で「*add password reset flow*」という Issue を file し、size-check SP が 8 — 大きすぎる — と返ってきたとする。親 Issue に対して `/breakdown 48` を実行する。Design は 4 つの Subtask 案を返してくる: password reset form の mockup を扱う `design-ui` subtask、email 送信 backend を扱う `develop` subtask、form 統合の `develop` subtask、rate-limit / abuse 対策の `develop` subtask、の 4 つだ。form に触れる 2 つの `develop` subtask は、`design-ui` subtask の review 完了を依存先に持つ。

ユーザが承認すると、Dev は親 Issue の下に 4 つの Subtask を書き込む: `github-only` なら GH Sub-issue、`linear+github` なら Linear subtask の形だ。各 Subtask は SP、type label、AC、parent link を持つ。form-integration subtask と design-ui subtask の依存は、`github-only` では body の `Depends on: #N` 行として、`linear+github` では Linear の "Blocked by" relation として記録される。

分解の結果が Subtask 1 つだけで、その作業が 1 つの PR にきれいに収まる場合、`/breakdown` は不要だ — `/refine` から直接 `/develop` に進める。分割が存在する理由は、PR-and-review の単位を verdict しやすいサイズに保つことにある。すでに PR サイズに収まる Issue でわざわざ実行する必要はなく、framework もそれを強制しない。

## Output

- 提案された Subtask リスト (title、type、SP、dependencies) — 承認待ちで提示。
- 承認後: 作成された Subtask の ID (`github-only` なら `#N`、`linear+github` なら `PRJ-N`)。
- 各 Subtask は type label (`type:develop` / `type:design-ui`) と parent-child link を持つ。

## 関連項目

- [agent と責務](/ja/concept/agent-responsibilities/) — Design が分解を提案し、Dev が登録する。
- [Issue サイズ](/ja/policies/issue-size/) — Issue が大きすぎて `suggest_split` が発火する条件。
- [Story points](/ja/policies/story-points/) — Subtask ごとに適用する SP スケール。
- [tracker profile](/ja/concept/tracker-profile/) — Subtask レコードの保存先。
- ライフサイクルの前のステップ: [`/refine`](/commands/refine/)。次のステップ: [`/develop`](/commands/develop/)。
- 正本の契約: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md)。
