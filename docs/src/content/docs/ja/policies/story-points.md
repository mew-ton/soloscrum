---
title: Story points
description: 2 段階の SP 構造 (Issue の size-check と subtask の登録値)、および scope × uncertainty を軸にした SP スケールを説明します。
sidebar:
  order: 3
---

Story points (SP) は scope と uncertainty を表す指標で、時間ではありません。soloscrum は 1 / 2 / 3 / 5 の 4 段階スケールを使います。SP が 5 を超える Issue は、`/develop` に進む前に分割します。

## スケール

| SP | Scope | Uncertainty | Calibration (observed, not the unit) |
|----|-------|-------------|---|
| 1  | 1 file / 1 concern | All decisions known | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 files / single skill area | 1 minor decision | ~100K-200K tokens, agent ~10-20 min |
| 3  | Single subsystem cross-cut | 1-2 design decisions | ~200K-500K tokens, agent ~20-45 min |
| 5  | Multi-subsystem cross-cut | Multiple design decisions | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (over-budget) | (over-budget) | Do not assign — split per [`issue-size`](/ja/policies/issue-size/) and re-estimate |

## 2 段階の SP

SP はライフサイクル上で 2 回登場します。

**Issue SP** はサイズチェック用です。PO が `/refine` で使い、その Issue がライフサイクルに進めるサイズか、それとも [`issue-size`](/ja/policies/issue-size/) で `suggest_split` をかけるべきかを判断します。Issue SP は **どこにも保存しません** — 判断のための入力であり、レコードではありません。

**Subtask SP** が実際に保存される値です。Dev が `/breakdown` の中で subtask の AC を読んで算出し、`soloscrum-tracker-{github|linear}-set-sp` で tracker に書き込みます。バックログの計画や進捗管理にはこちらの値を使います。

## なぜ時間ではなく scope × uncertainty なのか

時間を軸にしない理由があります。

- モデルの速度はリリースごとに変わります。今日の「2 時間」は来月「20 分」になります
- agent は並列で動くので、wall-clock 比較は歪みます
- 人間の時間と AI agent の時間は線形に対応しません

SP を時計単位に紐付けるとスケールが不安定になります。Calibration カラムは答え合わせの参考であって、入力ではありません。

## 見積もりの手順

Issue SP / Subtask SP のどちらでも同じ手順です。

1. AC と Goal を読み、スコープを把握する — いくつのサブシステム / concern に触れるか
2. uncertainty を測る — AC で確定していない設計判断はいくつ残っているか、新規性のある要素はあるか
3. (scope, uncertainty) を SP テーブルにマッピングする。両軸とも満たす必要があり、迷ったら大きい方を選ぶ
4. 5 を超えるなら over-budget — [`issue-size`](/ja/policies/issue-size/) で分割して見積もり直す

## 参考

- tracker profile ごとの SP の保存場所: [tracker profile](/ja/concept/tracker-profile/)
- canonical な契約: [`skills/soloscrum-define-story-points/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-story-points/SKILL.md)
