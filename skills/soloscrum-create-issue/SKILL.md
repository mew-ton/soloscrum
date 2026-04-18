---
name: soloscrum-create-issue
description: Structures an idea into a GitHub Issue with Background, Goal, AC, and Out of Scope. Checks issue size, suggests splitting if over threshold, and determines priority and story points.
argument-hint: <idea or feature description>
disable-model-invocation: true
---

# soloscrum-create-issue

アイデアをIssueに構造化・粒度判定・分割提案する。

## 概要

自由形式のアイデアや要望を受け取り、`soloscrum-define-issue-format` に従った GitHub Issue 形式に変換する。粒度が基準を超える場合は分割を提案する。

## 手順

1. 以下のアイデアや要望のテキストを受け取る: $ARGUMENTS
2. 以下の構造で Issue を作成する（`soloscrum-define-issue-format` 参照）
   - title: 動詞から始まる簡潔なタイトル
   - background: なぜこの機能が必要か
   - goal: 何を達成するか
   - acceptance_criteria: 検証可能な完了条件（箇条書き）
   - out_of_scope: 今回対象外のもの（明示する）
3. `soloscrum-define-issue-size` で粒度を評価する
4. 粒度超過の場合は分割案を作成してユーザーに提示する
5. `soloscrum-define-priority` で優先度を判定する
6. `soloscrum-define-story-points` で SP を算出する

## 出力形式

```markdown
## [Issue タイトル]

### Background
[背景・課題]

### Goal
[達成目標]

### Acceptance Criteria
- [ ] [検証可能な条件1]
- [ ] [検証可能な条件2]

### Out of Scope
- [対象外1]

---
Priority: Medium | SP: 3
```

## 依存スキル

- `soloscrum-define-issue-format`
- `soloscrum-define-issue-size`
- `soloscrum-define-priority`
- `soloscrum-define-story-points`
