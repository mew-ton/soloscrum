---
title: soloscrum — Claude agent と一緒に回す solo dev のスクラムループ
description: refine → breakdown → develop → review のスクラム的ループを AI agent と一緒に最後まで回すための Claude Code plugin です。
---

**soloscrum は、solo dev のスクラム的な開発ループを最後まで回すための Claude Code plugin です。** 各ステージには、動作範囲が明確に定義された AI agent が割り当てられています。

## 解こうとしている問題

solo dev は結局すべての役割を兼任します。アイデアを整理し、Issue を起票し、分解し、実装し、review し、いつ ship するかを決める、という具合です。役割を切り替えるたびに集中力が分散し、review / DoD / 「この Issue は形が整っているか」といった quality gate が真っ先にスキップされがちです。

soloscrum は、各役割を Claude agent に肩代わりさせます。役割ごとの契約があれば、2 人目の人間 reviewer に頼らずともループを回し続けられます。

## 構成要素

soloscrum は 4 つのパーツでできています。

- **skills** — フレームワークが契約として読み込む機械可読な仕様です。共通定義の `-define-*`、tracker profile 固有の `-tracker-*`、operation 単位の skill があります。リポジトリの `skills/` 配下に置きます。
- **agents** — 5 つの役割定義です。`soloscrum-po` (Product Owner)、`soloscrum-design` (Design)、`soloscrum-dev` (Dev)、`soloscrum-ui` (UI)、`soloscrum-review` (Review)。各 agent は自分が所有する概念だけを mutate します。
- **commands** — エントリポイントです。`/refine` / `/breakdown` / `/develop` / `/review` の 4 つがあります。
- **tracker profile** — `github-only` (default) または `linear+github` です。Subtask / SP / state の保存先を選びます。残りのフレームワークは profile に依存しません。詳細は [tracker profile](/ja/concept/tracker-profile/) を参照してください。

## ワークフロー

```text
/refine     → idea becomes a GitHub Issue with Background / Goal / AC / Out of Scope
/breakdown  → Issue's delivery slices into reviewable Subtask PRs when one PR would be unreviewable
/develop    → branch, implement, open a draft PR with `Closes #N`
/review     → DoD + AC + CodeRabbit + multi-agent review; verdict; ready handoff
```

最後の `gh pr merge` だけはユーザが実行します。irreversible なので、人間側に唯一残してあるステップです。それ以前のステップ (PR の作成・verdict の投稿・draft → ready の昇格・state の遷移) はすべて reversible で、command の中で自律的に走ります。

## Fit / not-fit

soloscrum が合うのは、次のような状況です。

- **solo developer** として (あるいは実質ひとりで — 変更ごとの人間 reviewer は最大 1 名) 動いている
- ワークフローの中心が **Claude Code** にあり、明示的な契約のもとであれば自律的に動かして構わない
- 作業が **GitHub Issue + PR** の上で流れている (breakdown レイヤーに Linear を併用するのも可)
- すべての PR で quality gate が必ず走ってほしい

soloscrum が合わないのは、次のような状況です。

- merge 前に **複数の人間 reviewer による approve** が必須である
- Claude Code 以外の AI agent への移植が必要 — soloscrum は Claude Code 専用です
- 主目的が人を組織化するためのフレームワーク — soloscrum は agent 向けの契約をコード化したものです

## 次のステップ

- [はじめに](/ja/onboarding/) — plugin のインストール、tracker profile の選択、最初の Issue を起票するまで
- [Concept](/ja/concept/tracker-profile/) — tracker profile、agent の責務、PR ライフサイクル、code review プロセス
- [Policies](/ja/policies/issue-format/) — `/refine` と `/review` が照らすルール (Issue フォーマット、サイズ、SP、優先度、DoD)
- [Commands](/ja/commands/refine/) — `/refine` / `/breakdown` / `/develop` / `/review` をライフサイクル順に解説

## AI 契約はどこにあるか

soloscrum の挙動を規定する正本は [リポジトリ](https://github.com/mew-ton/soloscrum) 側にあります。`skills/` / `agents/` / `commands/` / `CLAUDE.md` がそれです。このサイトは人間向けのコンパニオンです。spec ファイルは AI が読むために、このページは人間が読むために、それぞれ別の形で書かれています。
