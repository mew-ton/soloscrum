---
title: はじめに
description: 新しいリポジトリに soloscrum を導入する流れを 4 ステップで案内します。plugin インストール、tracker profile 選択、リポジトリルール設定、そして `/refine` で最初の Issue を起票するまでをカバーします。
sidebar:
  order: 1
---

新しいリポジトリに soloscrum を導入する流れを 4 ステップで案内します。このページを読み終えるころには、plugin がインストールされ、tracker profile が選ばれ、必要なリポジトリルールが置かれ、`/refine` で最初の Issue が起票された状態になります。

## 前提条件

- **Claude Code** をインストールし、認証を済ませてください
- **GitHub CLI (`gh`)** をインストールし、対象リポジトリを所有する GitHub アカウントで認証し、Issue と PR の読み書きができる状態にしてください
- **GitHub 上のリポジトリ** が必要です。soloscrum は tracker profile に関係なく、Issue の canonical なストアとして GitHub を使います
- (任意) **CodeRabbit CLI** の認証。`/review` は multi-agent pipeline の一部として CodeRabbit を実行します。なくても local quality gate は動きますが、強度は下がります
- (任意) **Linear MCP** の接続と GitHub→Linear のネイティブ同期設定。`linear+github` profile を使う場合だけ必要です

## Step 1 — plugin をインストールする

soloscrum は marketplace 経由で配布される Claude Code plugin です。Claude Code 内で次を実行してください。

```bash
/plugin marketplace add mew-ton/soloscrum
/plugin install soloscrum
```

別のリポジトリで以前インストール済みなら、`/plugin marketplace update soloscrum` で最新版を取り込んでください。

インストール後、`/refine` / `/breakdown` / `/develop` / `/review` の各 command が、そのリポジトリ上の Claude Code セッションで使えるようになります。

## Step 2 — tracker profile を選ぶ

**tracker profile** は、Subtask / SP / 依存関係 / state をどこに保存するかを決めます。

| Profile | 使う場面 |
|---|---|
| `github-only` | デフォルト。GitHub Issue のみが許可されている環境 (組織方針、公開 OSS など)。Subtask は GH ネイティブの Sub-issue、SP は GitHub Projects v2 の Number field に保存されます |
| `linear+github` | Linear MCP が利用でき、GitHub→Linear のネイティブ同期が設定済みのリポジトリ。Issue は GitHub に canonical を残し、Subtask と SP は Linear 側に置いて同期します |

詳細は [tracker profile](/ja/concept/tracker-profile/) を参照してください。

plugin のユーザ設定にはインストール時に取得する `tracker_profile` があります。特定のリポジトリでこれをオーバーライドしたい場合 (例: 普段は `linear+github` を使っているが、特定の OSS リポジトリでは GitHub だけ使いたい) は、リポジトリ直下に `.claude/rules/tracker.md` を置きます。

```markdown
---
profile: github-only
---
```

リポジトリローカルのオーバーライドはユーザ設定より優先されます。どちらも未設定なら、組み込みデフォルトの `github-only` が使われます。

## Step 3 — リポジトリルールを設定する (任意)

soloscrum は `.claude/rules/` 配下から任意のリポジトリ固有ルールを読み込みます。どれも必須ではありません。それぞれのファイルは、そのリポジトリでの agent の振る舞いを調整します。

| ファイル | 用途 |
|---|---|
| `.claude/rules/tracker.md` | tracker profile のオーバーライド (Step 2 参照) |
| `.claude/rules/stack.md` | `/develop` 時に Dev が参照する技術スタック、ディレクトリ構成、命名規約 |
| `.claude/rules/branch.md` | リポジトリ固有のブランチ戦略 (trunk-based / gitflow など、デフォルトの `<type>/<issue-id>-<slug>` から外れる場合) |
| `.claude/rules/dod-extra.md` | [coreチェックリスト](/ja/policies/dod/) に追記する DoD 項目 (例: 「新規 component には Storybook story を用意」「i18n の文字列を両ロケールに登録」) |
| `.claude/rules/pr.md` | always-draft PR のデフォルトを上書きする場合 (滅多に使いません。[PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照) |
| `.claude/rules/agent-overrides.md` | agent 責務マトリクスのリポジトリ固有調整 (ほぼ不要) |

いずれもプレーンな Markdown です。必要なオーバーライドだけ書いてください。ファイルがなければ soloscrum のデフォルトが適用されます。

## Step 4 — `/refine` で最初の Issue を起票する

リポジトリで Claude Code セッションを開き、次を実行してください。

```bash
/refine "<your idea here>"
```

最初の行に janitor sweep の結果が出ます。新規リポジトリでは `No stale Issues found` のはずです。続いて PO agent がアイデアを Background / Goal / AC / Out of Scope の 4 セクションに整形し、priority ラベルと size-check SP を提示します。確認して承認すると Issue が作成されます。

その後のライフサイクルは次の流れになります。

- size-check SP が 5 以下で 1 つの PR に収まるなら、Issue に対してそのまま [`/develop`](/ja/commands/develop/) を実行してください
- SP が 5 を超える、または複数サブシステムに跨る場合は、まず [`/breakdown`](/ja/commands/breakdown/) で Subtask に切ってから、各 Subtask に `/develop` を実行してください
- `/develop` が draft PR を開いたら、[`/review`](/ja/commands/review/) を実行してください。Pass の verdict が出ると `/review` は PR を ready に昇格させ、`gh pr merge` のコマンドを提示します。merge を実行するのはユーザの仕事で、agent の仕事ではありません

## 次に読むもの

- [Concept セクション](/ja/concept/tracker-profile/) — tracker profile、agent 責務、PR ライフサイクル、code review プロセス
- [Policies セクション](/ja/policies/issue-format/) — `/refine` と `/review` が照らすルール (Issue フォーマット、優先度、story points、Issue サイズ、DoD)
- [Commands セクション](/ja/commands/refine/) — `/refine` / `/breakdown` / `/develop` / `/review` の使い方
- canonical な spec: [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills) / [`agents/`](https://github.com/mew-ton/soloscrum/tree/main/agents) / [`commands/`](https://github.com/mew-ton/soloscrum/tree/main/commands)
