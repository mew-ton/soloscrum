---
title: はじめに
description: 新しいリポジトリに soloscrum を導入する流れ。plugin の install、tracker profile の選択、リポジトリ rule の設定、そして `/refine` で最初の Issue を file するところまで案内します。
sidebar:
  order: 1
---

このページは、新しいリポジトリに soloscrum を導入したい開発者向けです。最後まで読み終える頃には、plugin が install されていて、tracker profile が選ばれていて、必要であればリポジトリレベルの rule が設定されていて、`/refine` で最初の Issue が file されている状態になります。

## 前提条件

- **Claude Code** がインストール済みで、認証も済んでいること。
- **GitHub CLI (`gh`)** がインストール済みで、対象 repo を所有する GitHub アカウントで認証されていて、対象 repo の Issue / PR を読む・作成する・編集する権限があること。
- **GitHub 上のリポジトリ** があること。soloscrum は tracker profile に関わらず GitHub を canonical な Issue ストアとして扱います。
- (任意) **CodeRabbit CLI** が認証済みであること。`/review` は multi-agent pipeline の一部として CodeRabbit を実行します。なくても動きますが、ローカルの品質ゲートが弱くなります。
- (任意) **Linear MCP** が接続されていて、GitHub→Linear の native sync が設定済みであること。`linear+github` の tracker profile を使う場合にのみ必要です。

## Step 1 — plugin を install する

soloscrum は marketplace 経由で配布される Claude Code plugin です。Claude Code の中で次を実行します:

```bash
/plugin marketplace add mew-ton/soloscrum
/plugin install soloscrum
```

別の repo で過去に install したことがある場合は、最新版を取り込むために `/plugin marketplace update soloscrum` を実行してください。

install が終われば、soloscrum の command (`/refine`、`/breakdown`、`/develop`、`/review`) が、その repo に対する任意の Claude Code セッションで使えるようになります。

## Step 2 — tracker profile を選ぶ

soloscrum には、Subtask / SP / 依存関係 / state の保存先を切り替える **tracker profile** が 2 種類あります:

| Profile | 使う場面 |
|---|---|
| `github-only` | デフォルト。GitHub Issue だけを使う repo (組織の制約、public OSS など) 向け。Subtask は GitHub の native Sub-issue を使い、SP は GitHub Projects v2 の number field に保存されます。 |
| `linear+github` | Linear MCP が使えて、GitHub→Linear の native sync が設定済みの repo 向け。Issue は GitHub 上が canonical のまま、Subtask と SP は Linear に置かれて GitHub に戻し sync されます。 |

概念の詳細は [tracker profile](/ja/concept/tracker-profile/) で扱っています。

plugin のユーザ設定には install 時に決めた `tracker_profile` が記録されます。特定の repo だけ別の profile にしたい (例: グローバルでは `linear+github` を使っているが、ある OSS repo では GitHub しか使えない) ときは、その repo の root に次のような `.claude/rules/tracker.md` を置きます:

```markdown
---
profile: github-only
---
```

repo-local の override はユーザレベルのデフォルトより優先されます。どちらもない場合は、ビルトインフォールバックの `github-only` が使われます。

## Step 3 — repo rule を設定する (任意)

soloscrum は `.claude/rules/` の中のリポジトリ固有 rule を、あれば読み込みます。flow を動かすために必須なものはありませんが、各ファイルを置くとその repo での agent の振る舞いを引き締められます。

| ファイル | 制御するもの |
|---|---|
| `.claude/rules/tracker.md` | tracker profile の override (Step 2 を参照)。 |
| `.claude/rules/stack.md` | 技術スタック、ディレクトリ配置、命名規約。Dev が `/develop` 中に参照します。 |
| `.claude/rules/branch.md` | この repo 固有の branch 戦略 (例: trunk-based / gitflow)。soloscrum のデフォルト `<type>/<issue-id>-<slug>` から変える場合に置きます。 |
| `.claude/rules/dod-extra.md` | [core checklist](/ja/policies/dod/) に追加する DoD 項目。例:「新規コンポーネントには Storybook story を用意する」「i18n 文字列を両 locale に登録する」など。 |
| `.claude/rules/pr.md` | always-draft PR デフォルトの override (ほとんど不要。[PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照)。 |
| `.claude/rules/agent-overrides.md` | agent ownership matrix への repo 固有の調整。ほぼ不要です。 |

各ファイルは plain Markdown です。上書きしたい部分だけ書けば十分で、ファイルが存在しない場合は単に soloscrum のデフォルトが適用されます。

## Step 4 — `/refine` で最初の Issue を file する

これでライフサイクルを end-to-end で回す準備が整いました。repo で Claude Code のセッションを開き、次を実行します:

```bash
/refine "<your idea here>"
```

出力の 1 行目は janitor sweep の結果で、できたばかりの repo では `No stale Issues found` になります。続いて PO agent が、アイデアを 4 セクションの Issue 本文 (Background / Goal / AC / Out of Scope) に構造化し、priority ラベルを割り当てて、size-check SP を計算します。ユーザが確認すると、Issue が作成されます。

そこから先のライフサイクルは次のようになります:

- size-check SP が 5 以下で、作業が 1 つの PR に収まりそうなら、その Issue に対して直接 [`/develop`](/ja/commands/develop/) を実行します。
- SP が 5 を超えていたり、変更が明らかに複数の subsystem にまたがっていたりする場合は、先に [`/breakdown`](/ja/commands/breakdown/) を実行して Issue を Subtask に分割し、その後で各 Subtask に対して `/develop` を実行します。
- `/develop` が draft PR を開いたら、その PR に [`/review`](/ja/commands/review/) を実行します。Pass であれば `/review` が PR を ready に昇格させ、`gh pr merge` の command を提示します。最後の merge は agent ではなくユーザのゲートです。

## 次に読む場所

- [Concept セクション](/ja/concept/tracker-profile/) — tracker profile の意図、agent ownership ルール、PR ライフサイクル、code review プロセスの背景。
- [Policies セクション](/ja/policies/issue-format/) — `/refine` と `/review` が照合するルール (Issue format、priority、story points、issue size、DoD)。
- [Commands セクション](/ja/commands/refine/) — `/refine` / `/breakdown` / `/develop` / `/review` の command ごとのウォークスルー。
- 正本の spec はリポジトリ内: [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills)、[`agents/`](https://github.com/mew-ton/soloscrum/tree/main/agents)、[`commands/`](https://github.com/mew-ton/soloscrum/tree/main/commands)。
