---
title: 優先度
description: 優先度レベル (Urgent / High / Medium / Low) と、それぞれをどう判断するかを説明します。
sidebar:
  order: 2
---

Issue には 4 段階の優先度のいずれかが付きます。優先度はバックログの並び順を決め、その Issue をピックアップする側に緊急度を伝えます。

## 4 つの段階

| 優先度 | 判断基準 | 対応の目安 |
|---|---|---|
| **Urgent** | ブロッカー / 本番障害 / セキュリティ脆弱性 | 即時 |
| **High** | ユーザ影響が大きい、他の Issue が依存している | 次のサイクル |
| **Medium** | 通常の機能開発や改善 | バックログ順 |
| **Low** | 技術的負債 / リファクタリング / nice-to-have | 余裕がある時に |

優先度は GitHub Issue 上の `priority:{urgent|high|medium|low}` ラベルに保存します。tracker profile を問わず、優先度ラベルは GitHub 側に置きます。親 Issue のメタデータは GitHub を canonical とするためです。

## 判定フロー

```text
Production down or risk of data loss?
  → YES: Urgent

Other tasks are waiting on this, or high user impact?
  → YES: High

Normal feature development or improvement?
  → YES: Medium

Other (tech debt, future improvements)?
  → Low
```

## 適用される場面

`/refine` が Issue を作成するときにラベルを付けます。その後は基本的に変わりません — soloscrum が自動で優先度を再計算することはありません。変えたいときは Issue 上のラベルを直接編集します。

## メモ

- solo dev では Urgent と High が重なりがちです。Urgent は本当に時間との戦いになる状況のために残しておいてください。
- Medium が溜まってきたら、一部を Low に下げて後回しにしましょう。

## 参考

- ライフサイクル上の位置 (`/refine` で PO が付与する): [agent と責務](/ja/concept/agent-responsibilities/)
- canonical な契約: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md)
