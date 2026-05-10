---
title: 優先度
description: 優先度レベル (Urgent / High / Medium / Low) と決定基準。
sidebar:
  order: 2
---

Issue を起票するとき、あなた (もしくは `/refine`) は 4 段階の priority のうち 1 つを選びます。priority は backlog の順序を決め、Issue を pickup する人に緊急度を伝えます。

## 4 つのレベル

| Priority | 決定基準 | 対応目安 |
|---|---|---|
| **Urgent** | Blocker、本番障害、セキュリティ脆弱性 | 即座 |
| **High** | ユーザ影響大、他の Issue がこれに依存 | 次サイクル |
| **Medium** | 通常の機能開発と改善 | backlog 順に処理 |
| **Low** | 技術的負債、リファクタリング、nice-to-have | 余力あるとき |

レベルは GitHub Issue 上の `priority:{urgent|high|medium|low}` ラベルとして保存されます。ラベルは稼働中の tracker profile に関わらず GitHub 上にあります (両 profile で親メタデータについては GitHub が正本のままです)。

## 決定フロー

```text
本番ダウンまたはデータ損失リスクか?
  → YES: Urgent

他のタスクがこれを待っているか、ユーザ影響大か?
  → YES: High

通常の機能開発または改善か?
  → YES: Medium

その他 (技術的負債、将来の改善)?
  → Low
```

## いつ使われるか

`/refine` が Issue 作成時にラベルを付けます。その後レベルは sticky です — soloscrum が priority を自動的に再決定することはありません。変更したい場合は Issue のラベルを直接編集します。

## 注記

- solo development では Urgent と High はしばしば重なります。Urgent は本当に時間的に切迫した状況のみに予約してください。
- Medium が溜まりすぎる場合は、いくつかを Low にダウングレードして先送りすることを検討してください。

## 関連項目

- priority がライフサイクルのどこに位置するか (PO が `/refine` で割り当て): [agent と責務](/concept/agent-responsibilities/)。
- 正本の契約: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md)。
