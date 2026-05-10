---
title: define-priority
description: spec サマリ — priority レベル (Urgent / High / Medium / Low) と決定基準。
sidebar:
  order: 9
---

`soloscrum-define-priority` は 4 段階の priority 分類体系と、Issue をその上に配置するための決定フローです。

## 何をするか

priority スケールと各レベルの意味を固定します。

| Priority | 決定基準 | 対応目安 |
|---|---|---|
| **Urgent** | Blocker、本番障害、セキュリティ脆弱性 | 即座 |
| **High** | ユーザ影響大、他の Issue がこれに依存 | 次サイクル |
| **Medium** | 通常の機能開発と改善 | backlog 順に処理 |
| **Low** | 技術的負債、リファクタリング、nice-to-have | 余力あるとき |

## いつ消費されるか

`soloscrum-create-issue` (`/refine`) は新しい Issue にラベルを付けるためにこの skill を呼びます。ラベルは `priority:{urgent|high|medium|low}` で、稼働中の tracker profile に関わらず GitHub Issue 上にあります (両 profile で親メタデータについては GitHub が正本のままです)。

## 主要な入力と出力

入力は Issue の性質 (problem type、誰が影響を受けるか、他に何かが blocked されているか) です。出力は 4 つの priority ラベルのうちの 1 つです。

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

## 注記

- solo development では Urgent と High はしばしば重なります。Urgent は本当に時間的に切迫した状況のみに予約してください。
- Medium が溜まりすぎる場合は、いくつかを Low にダウングレードして先送りすることを検討してください。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md)。
- priority がライフサイクルのどこに位置するか (PO が `/refine` で割り当て、自動的に再決定されることはない) については、[agent と責務](/concept/agent-responsibilities/) を参照。
