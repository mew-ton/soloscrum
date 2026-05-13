---
title: Definition of Done
description: soloscrum の subtask に適用する Definition of Done チェックリストを説明します。
sidebar:
  order: 5
---

`/review` が Pass の verdict を出すには、subtask が 6 つの条件をすべて満たしている必要があります。verdict コメントはこのチェックリストに照らして書かれます。

## チェックリスト

- [ ] すべての AC が満たされている
- [ ] テストが存在する (該当する場合)
- [ ] PR 本文に Issue 番号が含まれている (`Closes #N` / `Fixes #N` / `Resolves #N` のいずれか)
- [ ] lint エラーがゼロ
- [ ] code review pipeline を実行し、finding を処理している ([code review プロセス](/ja/concept/code-review-process/) を参照)
- [ ] review が pass している

各項目には個別のルールがあります。

- 「テストが存在する」が適用されるのは business logic / API endpoint / utility function などです。ロジックを伴わない設定変更は対象外です。
- 「Issue 番号」は GitHub が認識する auto-close キーワードのいずれかである必要があります。

## 適用される場面

DoD を確認する場面は 2 つあります。

- `/develop` 中、Dev agent が「review が pass している」以外の全項目を自己チェックします。review の verdict だけは Dev が自分で出せません。
- `/review` 中、6 項目すべてを検証します。verdict コメントは項目ごとに OK / Not OK と理由を並べます。

## リポジトリ固有の追加項目

リポジトリ側で `.claude/rules/dod-extra.md` に DoD 項目を追加できます。core のリストを置き換えるのではなく、末尾に追記される形になります。

## 参考

- auto-close キーワードが必要な理由: [PR ライフサイクル](/ja/concept/pr-lifecycle/)
- canonical な契約: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md)
