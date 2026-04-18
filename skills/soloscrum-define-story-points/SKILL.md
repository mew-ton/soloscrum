---
name: soloscrum-define-story-points
description: Reference: story point scale and estimation criteria. SP 1=2h, 2=half day, 3=1 day, 5=2 days. Issues estimated over SP 5 must be split before proceeding.
user-invocable: false
---

# soloscrum-define-story-points

SPの定義と算出基準。

## SP の二段階構造

soloscrum では SP の見積もりを **Issue レベル（PO レイヤー）** と **subtask レベル（Dev レイヤー）** の二段階で行う。

### なぜ二段階なのか

タスクは原則として無限に細分化できる。「アプリを実装する」「認証機能を作る」「ログイン画面を作る」のように、ルートに置くタスクのスコープは自由に設定できる。

このため、breakdown（subtask分解）の前に「このIssueはそもそも管理可能な粒度か」を判断するレイヤーが必要になる。粒度が大きすぎるまま breakdown に進むと、subtask が膨大になり管理が破綻する。

PO レイヤーでの軽量見積もりは、この **入口ゲート** として機能する。

### Issue SP（PO レイヤー）

- **目的**: Issue が管理可能な粒度かどうかを判定する
- **実施者**: `po-agent`（`/refine` 時）
- **精度**: 大まかで構わない。細部まで詰めずに概算する
- **閾値**: SP 5 超、または推定2日超で `suggest_split` を実行する
- **Linear への登録**: しない（あくまで粒度チェック用）

Issue SP が閾値を超えた場合は、`soloscrum-define-issue-size` の基準に従ってIssueを分割し、再見積もりする。

### subtask SP（Dev レイヤー）

- **目的**: Linear に登録する実値。実装の計画・進捗管理に使う
- **実施者**: `dev-agent`（`/breakdown` 時）
- **精度**: AC・影響ファイル数・新規性を精査した上で算出する
- **Linear への登録**: する（subtask の estimate フィールドにセット）

---

## SP テーブル

| SP | 目安工数 | 複雑度の目安 |
|---|---|---|
| 1 | 2時間以内 | 明確な変更、1〜2ファイル、テスト容易 |
| 2 | 半日（〜4時間） | 小規模な機能追加、3〜5ファイル |
| 3 | 1日（〜8時間） | 中規模な機能追加、複数コンポーネント連携 |
| 5 | 2日（〜16時間） | 大規模な機能追加、新しいパターン導入 |
| 5超 | 出さない | → Issue を分割して再見積もりする |

SP テーブルは Issue SP・subtask SP 共通で使用する。

## 算出手順

### Issue SP（PO レイヤー）

1. Issue の Goal と AC の量・複雑さを概観する
2. 「この Issue を一人で実装するとしたら何日かかるか」を直感で見積もる
3. SP テーブルに当てはめる
4. SP 5 超または推定2日超の場合は Issue を分割する

### subtask SP（Dev レイヤー）

1. subtask の AC 数・影響ファイル数・新規性を評価する
2. 不確実性が高い場合は 1 段階上げる
3. SP 5 を超える見積もりになる場合は Issue 分割が漏れている可能性があるためユーザーに確認する

## 注意

- SP はコード行数ではなく**複雑度と不確実性**で決める
- 個人開発なのでチームの平均速度は考慮しない
- 過去の実績と照らして過小・過大評価を避ける
