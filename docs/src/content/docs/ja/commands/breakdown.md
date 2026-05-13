---
title: /breakdown
description: サイズ閾値を超えた Issue を、type と SP を持つ Subtask に分割し、active tracker に登録します。
sidebar:
  order: 2
---

`/breakdown` は、単一の PR で扱うには大きすぎる Issue — size-check SP が 5 を超えるか、複数のサブシステムに跨るような Issue — を Subtask のリストに切り分けます。各 Subtask には type (`develop` か `design-ui`) を付け、1 つの PR で満たせるサイズに収めます。最後に active tracker に書き込みます。

## 使い方

```bash
/breakdown <issue-url or issue-number>
```

引数は親 Issue です。URL 形式 (`https://github.com/<owner>/<repo>/issues/<n>`)、番号のみ (`#48` / `48`) のどちらも使えます。

## 処理の流れ

1. **Issue を読む。** Design agent が親 Issue の Background / Goal / AC / Out of Scope を読みます。
2. **分割案を作る。** Design が Subtask のリストを提案します。各項目に title / type (`develop` はコード、`design-ui` は Figma 作業) / AC、必要なら Subtask 間の blocking 関係 (例: *Subtask B は Subtask A に依存*) を付けます。
3. **検証。** Design が分割案に対してサイズチェックを再実行します。まだ大きい Subtask が残っていたり、Subtask の総数が 5 を超えるなら、分割テストが再発火し、提案を作り直します。
4. **承認。** 分割案を提示し、tracker に書き込む前にユーザの承認を取ります。
5. **登録。** 承認後、Dev agent が `soloscrum-tracker-{github|linear}-create-subtask` で各 Subtask を書き込みます。SP は各 Subtask の AC を読んでから [story points](/ja/policies/story-points/) のスケールで付けます。Subtask 間の依存関係は `soloscrum-tracker-{github|linear}-add-dependency` で登録します。

## 典型的な流れ

`/refine` で *"add password reset flow"* を起票したところ、size-check SP が 8 と返ってきて分割が必要になりました。親 Issue に対して `/breakdown 48` を走らせます。Design は 4 つの Subtask に分割した提案を返してきます。

- パスワード reset フォームの mockup を作る `design-ui` subtask
- メール送信 backend の `develop` subtask
- フォーム統合の `develop` subtask
- rate-limit / abuse 対策の `develop` subtask

フォームに触れる 2 つの `develop` subtask は、`design-ui` 側の review が完了するのを待ちます。

承認すると、Dev が親 Issue 配下に 4 つの Subtask を書き込みます。`github-only` なら GH の Sub-issue、`linear+github` なら Linear の subtask です。各 Subtask は SP / type ラベル / AC / 親リンクを持ちます。フォーム統合 → design-ui の依存関係も記録され、`github-only` なら `Depends on: #N` 行、`linear+github` なら Linear の "Blocked by" 関係として表現されます。

分割した結果、Subtask が 1 つだけで、しかも 1 つの PR にきれいに収まる場合は、`/breakdown` をスキップして `/refine` から直接 `/develop` に進めます。`/breakdown` は PR と review のサイズを verdict を出しやすい単位に保つために存在します。

## 出力

- 提案された Subtask リスト (title / type / SP / 依存関係) — 承認用に表示します
- 承認後: 作成した Subtask の ID (`github-only` なら `#N`、`linear+github` なら `PRJ-N`)
- 各 Subtask には type ラベル (`type:develop` / `type:design-ui`) と親子リンクが付きます

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — Design が分割案を作り、Dev が登録します
- [Issue サイズ](/ja/policies/issue-size/) — Issue が大きすぎると判定され `suggest_split` が走る条件
- [Story points](/ja/policies/story-points/) — Subtask ごとに付ける SP スケール
- [tracker profile](/ja/concept/tracker-profile/) — Subtask レコードの保存先
- 前: [`/refine`](/ja/commands/refine/) / 次: [`/develop`](/ja/commands/develop/)
- canonical な契約: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md)
