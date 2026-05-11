---
title: Story points
description: 2 段階の SP 構造 (Issue の size-check と Subtask への登録) と、scope × uncertainty を軸にした SP スケール。
sidebar:
  order: 3
---

Story points (SP) が測るのは scope × uncertainty であって、時間ではない。soloscrum では 1/2/3/5 のスケールを採用しており、SP > 5 になった Issue は `/develop` に入る前に分割が必須となる。

## SP スケール

| SP | Scope | Uncertainty | 校正 (観測値であって単位ではない) |
|----|-------|-------------|---|
| 1  | 1 ファイル / 1 関心事 | 決定はすべて既知 | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 ファイル / 単一スキル領域 | 軽微な決定が 1 つ | ~100K-200K tokens, agent ~10-20 min |
| 3  | 単一サブシステム横断 | 設計決定が 1-2 個 | ~200K-500K tokens, agent ~20-45 min |
| 5  | 複数サブシステム横断 | 設計決定が複数 | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (予算超過) | (予算超過) | 割り当てない — [`issue-size`](/ja/policies/issue-size/) に従って分割し、再見積もりする |

## 2 つの段階

SP はライフサイクルの 2 か所に登場する:

**Issue SP** はざっくり度合いのチェックだ。PO は `/refine` で、Issue がそのままライフサイクルに乗せられるサイズか、それとも先に [`issue-size`](/ja/policies/issue-size/) が `suggest_split` を発火させる必要があるかを判断するためにこれを使う。値はどこにも保存され **ない** — レコードではなく、決定のための入力にすぎない。

**Subtask SP** は実際に記録される値だ。Dev が `/breakdown` の中で subtask の AC を読み解いて計算し、`soloscrum-tracker-{github|linear}-set-sp` で tracker に書き込む。backlog のプランニングや進捗追跡で使われるのはこちらだ。

## なぜ scope × uncertainty で、時間ではないのか

時間アンカーを単位にしないのは意図的な選択だ。モデルの速度はリリースごとに変動する (今日の「2 時間」は来月には「20 分」になる)。agent は並列で動くので wall-clock の比較も歪む。さらに、人間の時間と AI agent の時間は線形には対応しない。SP を時計単位に固定するとスケールが不安定になる、というのが過去の結論だ。校正カラムはあくまで sanity-check のためにあり、見積もりの入力ではない。

## 見積もり手順

どちらの段階でも、手順は共通だ:

1. AC / Goal を読み、scope を見極める: 触れるサブシステム / 関心事はいくつか。
2. uncertainty を見極める: AC を読んだ後にまだ未解決の設計決定がいくつ残るか。新規要素はあるか。
3. (scope, uncertainty) を SP 表にマッピングする。両軸とも収まる必要がある。迷ったら高い行を選ぶ。
4. 結果が 5 を超えたら、その Issue は予算超過だ。[`issue-size`](/ja/policies/issue-size/) に従って分割し、再見積もりする。

## 関連項目

- tracker profile ごとの SP の保存先: [tracker profile](/ja/concept/tracker-profile/)。
- 正本の契約: [`skills/soloscrum-define-story-points/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-story-points/SKILL.md)。
