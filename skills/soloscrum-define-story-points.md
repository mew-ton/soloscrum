---
name: soloscrum-define-story-points
description: Reference: story point scale and estimation criteria. SP 1=2h, 2=half day, 3=1 day, 5=2 days. Issues estimated over SP 5 must be split before proceeding.
user-invocable: false
---

# soloscrum-define-story-points

SPの定義と算出基準。

## SP テーブル

| SP | 目安工数 | 複雑度の目安 |
|---|---|---|
| 1 | 2時間以内 | 明確な変更、1〜2ファイル、テスト容易 |
| 2 | 半日（〜4時間） | 小規模な機能追加、3〜5ファイル |
| 3 | 1日（〜8時間） | 中規模な機能追加、複数コンポーネント連携 |
| 5 | 2日（〜16時間） | 大規模な機能追加、新しいパターン導入 |
| 5超 | 出さない | → Issue を分割して再見積もりする |

## 算出手順

1. subtask の AC 数・影響ファイル数・新規性を評価する
2. 不確実性が高い場合は 1 段階上げる
3. SP 5 を超える見積もりになる場合は `soloscrum-define-issue-size` の `suggest_split` を実行する

## 注意

- SP はコード行数ではなく**複雑度と不確実性**で決める
- 個人開発なのでチームの平均速度は考慮しない
- 過去の実績と照らして過小・過大評価を避ける
