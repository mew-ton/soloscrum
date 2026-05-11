---
title: 優先度
description: 優先度レベル (Urgent / High / Medium / Low) と決定基準。
sidebar:
  order: 2
---

Issue を起票するとき、ユーザ (または `/refine`) は 4 段階の priority から 1 つを選ぶ。priority は backlog の順序を決め、その Issue を pickup する人に緊急度を伝える役割を持つ。

## 4 つのレベル

| Priority | 決定基準 | 対応目安 |
|---|---|---|
| **Urgent** | blocker、本番障害、セキュリティ脆弱性 | 即時 |
| **High** | ユーザ影響が大きい、他の Issue がこれに依存している | 次サイクル |
| **Medium** | 通常の機能開発や改善 | backlog 順に処理 |
| **Low** | 技術的負債、リファクタリング、nice-to-have | 余力があるとき |

レベルは GitHub Issue の `priority:{urgent|high|medium|low}` ラベルとして保存する。稼働中の tracker profile に関わらずラベルは GitHub 上に置かれる (どちらの profile でも親メタデータの正本は GitHub だからだ)。

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

## いつ適用されるか

`/refine` が Issue 作成時にラベルを付ける。以後、レベルは sticky だ — soloscrum が自動で再決定することはない。変えたい場合は Issue のラベルを直接編集する。

## 注記

- solo development では Urgent と High が重なる場面が多い。Urgent は本当に時間的に切迫した状況にだけ取っておく。
- Medium が溜まりすぎたときは、いくつかを Low に下げて先送りすることを検討する。

## 関連項目

- priority がライフサイクルのどこに位置するか (PO が `/refine` で割り当てる): [agent と責務](/ja/concept/agent-responsibilities/)。
- 正本の契約: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md)。
