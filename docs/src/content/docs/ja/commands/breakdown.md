---
title: /breakdown
description: 大きいが一貫した Issue の配信を、reviewable な Subtask にスライスします。Subtask は work をスライスするものであって intent ではない — 自分の AC は持ちません。1 つの PR で出すとレビュー不能になるときに発火します。
sidebar:
  order: 2
---

`/breakdown` は、intent は一貫しているが配信を 1 つの reviewable PR に収められない Issue をスライスします。各 Subtask は親の配信のうちの 1 つの reviewable スライスで、type (`develop` か `design-ui`) を持ち、1 PR 分のサイズに収めますが、自分の Acceptance Criteria は持ちません — AC は親 Issue が持ちます。

size-check SP・subtask 数・[`issue-size`](/ja/policies/issue-size/) の他の signal が「**複数 intent が束ねられている**」と示しているなら、`/breakdown` ではなく [`/refine`](/ja/commands/refine/) で Issue 自体を分割します。

## 使い方

```bash
/breakdown <issue-url or issue-number>
```

引数は親 Issue です。URL 形式 (`https://github.com/<owner>/<repo>/issues/<n>`)、番号のみ (`#48` / `48`) のどちらも使えます。

## 処理の流れ

1. **`/breakdown` が適切かを確認する。** [`issue-size`](/ja/policies/issue-size/) のとおり、`/breakdown` は「Issue の intent を単一 PR で配信したら unreviewable になるとき」だけ発火します。診断が「複数 intent が束ねられている」なら、Design agent は `/refine` に差し戻します。
2. **Issue を読む。** Design が親 Issue の Background / Goal / AC / Out of Scope を読みます。
3. **配信スライスを設計する。** Design が Subtask のリストを提案します。各 Subtask は 1 つの reviewable PR 分の作業で、title / type / 「親 intent のどの部分を届けるスライスか」の 1 行 / 任意の concrete step のチェックリスト / 必要なら Subtask 間の依存関係を持ちます。Subtask は自分の Background / Goal / AC / Out of Scope を**持ちません** — [`issue-format`](/ja/policies/issue-format/) の Subtask 本文セクションを参照。
4. **検証。** Design が分割案に対してサイズチェックを再実行します。subtask 数が 5 を超えるなら mis-scope の臭いとみなし（Issue が複数 intent を束ねている可能性が高い）、`/refine` に差し戻します。
5. **承認。** 分割案を提示し、tracker に書き込む前に user の承認を取ります。
6. **登録。** 承認後、Dev agent が `soloscrum-tracker-{github|linear}-create-subtask` で各 Subtask を書き込みます。SP は [story points](/ja/policies/story-points/) スケールで Subtask ごとに付けます。Subtask 間の依存関係は `soloscrum-tracker-{github|linear}-add-dependency` で登録します。

## 典型的な流れ

`/refine` で *"add password reset flow"* を起票したところ、size-check SP は 5 — intent は一貫している（ユーザがパスワードを再設定できる、という 1 つの why）が、配信が複数の subsystem に跨っていて 1 つの reviewable PR には収まりません。親 Issue に対して `/breakdown 48` を走らせます。Design は 4 つの Subtask に分割した提案を返してきます — これらは配信スライスであって sub-intent ではありません。

- パスワード reset フォームの mockup を作る `design-ui` Subtask
- メール送信 backend の `develop` Subtask
- フォーム統合の `develop` Subtask
- rate-limit / abuse 対策の `develop` Subtask

フォーム統合 Subtask は `design-ui` Subtask に依存します。どの Subtask も自分の AC を持ちません — 親 Issue の AC（*"user can reset their password via email"*）が、4 つすべてが揃ったときに満たされます。

承認すると、Dev が親 Issue 配下に 4 つの Subtask を書き込みます。`github-only` なら GH の Sub-issue、`linear+github` なら Linear の subtask です。各 Subtask は SP / type ラベル / 親リンクを持ちます。フォーム統合 → design-ui の依存関係も記録され、`github-only` なら `Depends on: #N` 行、`linear+github` なら Linear の "Blocked by" 関係として表現されます。

1 つの PR にきれいに収まる作業なら、`/breakdown` をスキップして `/refine` から直接 `/develop` に進めます。

## 出力

- 提案された Subtask リスト (title / type / SP / 依存関係) — 承認用に表示します
- 承認後: 作成した Subtask の ID (`github-only` なら `#N`、`linear+github` なら `PRJ-N`)
- 各 Subtask には type ラベル (`type:develop` / `type:design-ui`) と親子リンクが付きます

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — Design が分割案を作り、Dev が登録します
- [Issue サイズ](/ja/policies/issue-size/) — Issue が大きすぎて `suggest_split` が走るのか、単に `/breakdown` 対象なのかの判別
- [Issue フォーマット](/ja/policies/issue-format/) — Subtask 本文の契約（AC を持たない）
- [Story points](/ja/policies/story-points/) — Subtask ごとに付ける SP スケール
- [tracker profile](/ja/concept/tracker-profile/) — Subtask レコードの保存先
- 前: [`/refine`](/ja/commands/refine/) / 次: [`/develop`](/ja/commands/develop/)
- canonical な契約: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md)
