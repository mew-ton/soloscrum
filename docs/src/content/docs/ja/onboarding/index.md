---
title: はじめに
description: 新しいリポジトリに soloscrum を導入する — plugin install、tracker profile の選択、リポジトリ rule の設定、`/refine` で最初の Issue を file するところまで。
sidebar:
  order: 1
---

このページは、新しいリポジトリに soloscrum を導入する開発者向けです。最後まで読むと、plugin が install され、tracker profile が選択され、必要に応じてリポジトリレベルの rule が設定され、`/refine` 経由で最初の Issue が file された状態になります。

## 前提条件

- **Claude Code** がインストール・認証済み。
- **GitHub CLI (`gh`)** がインストールされ、対象 repo を所有する GitHub アカウントで認証済み、対象 repo の Issue / PR を読み・作成・編集できる権限がある。
- **GitHub 上のリポジトリ** — soloscrum は tracker profile に関わらず GitHub を canonical な Issue ストアとして扱う。
- (任意) **CodeRabbit CLI** が認証済み — `/review` は multi-agent pipeline の一部として CodeRabbit を実行する; 無くても動作するが local quality gate は弱くなる。
- (任意) **Linear MCP** が接続され GitHub→Linear の native sync が設定済み — `linear+github` tracker profile を使う場合のみ必要。

## Step 1 — plugin を install する

soloscrum は marketplace 経由で配布される Claude Code plugin です。Claude Code 内から:

```bash
/plugin marketplace add mew-ton/soloscrum
/plugin install soloscrum
```

別の repo で以前 install したことがある場合、最新版を pull するために `/plugin marketplace update soloscrum` を実行してください。

install 後、soloscrum command (`/refine`, `/breakdown`, `/develop`, `/review`) が repo に対する任意の Claude Code セッションで利用可能になります。

## Step 2 — tracker profile を選ぶ

soloscrum は Subtask、SP、依存関係、state がどこに保存されるかを制御する 2 つの **tracker profile** をサポートします:

| Profile | 使用場面 |
|---|---|
| `github-only` | デフォルト。GitHub Issue のみを許可する repo (組織制約、public OSS など)。Subtask は GitHub native Sub-issue を使い、SP は GitHub Projects v2 number field に住む。 |
| `linear+github` | Linear MCP が利用可能で GitHub→Linear native sync が設定済みの repo。Issue は GitHub 上で canonical のまま; Subtask と SP は Linear に住み、戻し sync される。 |

概念は [tracker profile](/ja/concept/tracker-profile/) で詳しく扱います。

plugin user config は install 時に取得される `tracker_profile` 設定を expose します。特定の repo で override する (例: グローバルでは `linear+github` がデフォルトだが、特定の OSS repo では GitHub のみ許可) には、repo の root に frontmatter 付きの `.claude/rules/tracker.md` ファイルを置きます:

```markdown
---
profile: github-only
---
```

repo-local の上書きはユーザレベルのデフォルトより優先されます。両方ともない場合、`github-only` が built-in fallback です。

## Step 3 — repo rule を設定する (任意)

soloscrum は `.claude/rules/` から任意のリポジトリ固有 rule を読み込みます。flow を実行するのに必須なものはありません; 各ファイルはその repo の agent の振る舞いを締めます。

| ファイル | 制御対象 |
|---|---|
| `.claude/rules/tracker.md` | tracker profile 上書き (Step 2 を参照)。 |
| `.claude/rules/stack.md` | 技術スタック、ディレクトリ配置、命名規約 — Dev が `/develop` 中に参照。 |
| `.claude/rules/branch.md` | この repo に固有の branch 戦略 (例: trunk-based vs gitflow)、soloscrum のデフォルト `<type>/<issue-id>-<slug>` 形式から divergent な場合。 |
| `.claude/rules/dod-extra.md` | [core checklist](/ja/policies/dod/) に追加される DoD 項目 — 例: 「全新規コンポーネントに Storybook story が存在」「i18n 文字列が両 locale に登録済み」。 |
| `.claude/rules/pr.md` | always-draft PR デフォルトの任意の上書き (ほぼ不要; [PR lifecycle](/ja/concept/pr-lifecycle/) を参照)。 |
| `.claude/rules/agent-overrides.md` | agent ownership matrix への repo 固有の調整 — ほぼ不要。 |

各ファイルは plain Markdown です。上書きしたい部分だけ追加してください; 欠けているファイルは soloscrum のデフォルトが適用されることを意味するだけです。

## Step 4 — `/refine` で最初の Issue を file する

これでライフサイクルを end-to-end で駆動する準備ができました。repo で Claude Code セッションを開き、実行します:

```bash
/refine "<your idea here>"
```

出力の最初の行は janitor sweep — 真新しい repo では `No stale Issues found` です。次に PO agent がアイデアを 4 セクションの Issue 本文 (Background / Goal / AC / Out of Scope) に構造化し、priority ラベルを割り当て、size-check SP を計算します。ユーザが確認すると、Issue が作成されます。

そこからライフサイクルは:

- size-check SP が 5 以下で作業が 1 つの PR に収まるなら、Issue に対して直接 [`/develop`](/ja/commands/develop/) を実行。
- SP が 5 を超えるか変更が明らかに複数 subsystem にまたがる場合、まず [`/breakdown`](/ja/commands/breakdown/) を実行して Issue を Subtask に分割し、各 Subtask に `/develop` を実行。
- `/develop` が draft PR を開いた後、その PR に対して [`/review`](/ja/commands/review/) を実行。Pass なら `/review` が PR を ready に昇格させ、`gh pr merge` command を surface します — その最終 merge は agent ではなくユーザのゲートです。

## 次に行く場所

- [Concept セクション](/ja/concept/tracker-profile/) — tracker profile の理由、agent ownership rule、PR lifecycle、code review process の why。
- [Policies セクション](/ja/policies/issue-format/) — `/refine` と `/review` が照合する rule (Issue format、priority、story points、issue size、DoD)。
- [Commands セクション](/ja/commands/refine/) — `/refine`, `/breakdown`, `/develop`, `/review` の command ごとのウォークスルー。
- 正本の spec: リポジトリ内の [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills), [`agents/`](https://github.com/mew-ton/soloscrum/tree/main/agents), [`commands/`](https://github.com/mew-ton/soloscrum/tree/main/commands)。
