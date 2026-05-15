---
title: Definition of Done
description: soloscrum の subtask に適用する Definition of Done チェックリストを説明します。
sidebar:
  order: 5
---

`/review` が Pass の verdict を出すには、subtask が 6 つの条件をすべて満たしている必要があります。verdict コメントはこのチェックリストに照らして書かれます。

## チェックリスト

- [ ] AC を適切なレイヤーで検証している（下の *AC 検証* セクションを参照）
- [ ] テストが存在する (該当する場合)
- [ ] PR 本文に Issue 番号が含まれている (`Closes #N` / `Fixes #N` / `Resolves #N` のいずれか) — Subtask PR では `#<subtask>`、Subtask を持たない Issue では `#<issue>`。[branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) のとおり、Subtask PR は `Closes #<parent>` を**含めません**
- [ ] lint エラーがゼロ
- [ ] code review pipeline を実行し、finding を処理している ([code review プロセス](/ja/concept/code-review-process/) を参照)
- [ ] review が Pass している

各項目には個別のルールがあります。

- 「テストが存在する」が適用されるのは business logic / API endpoint / utility function などです。ロジックを伴わない設定変更は対象外です。
- 「Issue 番号」は GitHub が認識する auto-close キーワードのいずれかである必要があります。

## AC 検証

AC 検証は 2 つのレイヤーで動きます。Subtask は work をスライスするものであって intent をスライスするものではないため（[issue-format](/ja/policies/issue-format/) の Subtask 本文を参照）、PR の種類によって検証範囲が変わります。

- **Subtask PR。** スライスが配信されたこと（"what" と Checklist 項目）と、退行がないこと（直前まで満たされていた親 AC が今は壊れていないか）を確認します。親 Issue の AC が完全に満たされていることは、この PR では要求されません。
- **Subtask を持たない Issue**（単一 `/develop` 単位の Issue）。Issue の全 AC が満たされていることを、エビデンス（スクリーンショット、テスト結果など）付きで確認します。PR は `Closes #<issue>` で Issue を直接 close します。
- **親 Issue（Subtask あり） — intent 単位の AC サインオフ。** 親の全 AC は、すべての Subtask が close したタイミングで検証します。個別 Subtask PR の段階では確認しません。最後の Subtask PR が merge されたとき、`/refine` janitor が親を close します。そのとき、親の AC は Subtask 群の配信物の和集合から満たせている必要があります。

## 適用される場面

DoD を確認する場面は 2 つあります。

- `/develop` 中、Dev agent が「review が Pass している」以外の全項目を自己チェックします。review の verdict だけは Dev が自分で出せません。
- `/review` 中、6 項目すべてを検証します。verdict コメントは項目ごとに OK / Not OK と理由を並べます。

## リポジトリ固有の追加項目

リポジトリ側で `.claude/rules/dod-extra.md` に DoD 項目を追加できます。core のリストを置き換えるのではなく、末尾に追記される形になります。

## 参考

- auto-close キーワードが必要な理由: [PR ライフサイクル](/ja/concept/pr-lifecycle/)
- canonical な契約: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md)
