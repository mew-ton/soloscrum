---
title: soloscrum — Claude agent と回す solo dev のスクラムループ
description: 個人開発者が refine → breakdown → develop → review のスクラム的ループを AI agent と一緒に最後まで回せる Claude Code plugin。
---

**soloscrum は、個人開発者が AI agent と一緒にスクラム的な開発ループを回すための Claude Code plugin フレームワークです。**

## 解こうとしている問題

ひとりでプロジェクトを通す solo dev は、すべての役割を兼任することになります。アイデアを整理し、Issue を file し、分解し、実装し、レビューし、いつ ship するかを決める。役割間のコンテキストスイッチで集中力が削られ、品質を担保するための工程 — review ゲート、DoD チェック、「この Issue はそもそも well-formed か」を見直すパス — は、ひとりしかいない部屋でいちばん最初にスキップされます。

soloscrum の賭けは、**役割ごとに十分厳格な契約を framework 側で持たせれば、Claude agent がそれらの役割を肩代わりできる**というものです。契約は、誰も見ていなくてもループが正直に回り続けるための拘束です。

## 構成要素

soloscrum は 4 つの構成要素からなります:

- **skills** — framework が契約として読む機械可読な仕様（共通定義の `-define-*`、tracker profile 固有の `-tracker-*`、operation 単位の skill）。リポジトリの `skills/` 配下に置かれます。
- **agents** — 5 つのロール定義: `soloscrum-po` (Product Owner)、`soloscrum-design` (Design)、`soloscrum-dev` (Dev)、`soloscrum-ui` (UI)、`soloscrum-review` (Review)。各 agent は自分が所有する概念しか mutate しません。
- **commands** — ユーザーが直接叩くエントリ: `/refine`, `/breakdown`, `/develop`, `/review`。
- **tracker profile** — `github-only` (デフォルト) または `linear+github`。Subtask / SP / state をどこに置くかを決めます。残りの framework は profile 非依存です。詳細は [tracker profile](/ja/concept/tracker-profile/) を参照。

## ワークフロー

```
/refine     → アイデアを Background / Goal / AC / Out of Scope を備えた GitHub Issue にする
/breakdown  → サイズ閾値を超えた Issue を Sub-issue に分割する
/develop    → branch を切り、実装し、`Closes #N` を含む draft PR を開く
/review     → DoD + AC + CodeRabbit + multi-agent review → verdict → ready 引き渡し
```

最後の `gh pr merge` はユーザーが実行します。これは irreversible なので、唯一人間側に残してある手動ステップです。それ以前のステップ（PR 作成、verdict 投稿、draft → ready 昇格、state 遷移）はすべて reversible で、コマンド内で自律的に走ります。

## Fit / not-fit

以下の場合に soloscrum は fit します:

- **solo developer** である（または実質ひとりで回している — 変更ごとに人間 reviewer がせいぜい 1 人）。
- ワークフローの中心が **Claude Code** で、明示的な契約のもとで自律的に動作させることを許容できる。
- 作業が **GitHub Issue + PR** で流れる（breakdown レイヤーに Linear を追加するのは可）。
- 「気が向いた時に review してもらう」ではなく、**毎 PR で品質ゲートを通す**ことを望んでいる。

以下の場合は fit しません:

- merge 前に **複数の人間 reviewer による approve** が必須要件である。
- **複数の AI agent への移植性** が必要である — soloscrum は Claude Code plugin であることを前提に組まれています。
- 人を組織化するのが主目的のプロセスフレームワークが欲しい — soloscrum はあくまで agent 向けの契約をコード化したものです。

## 次のステップ

- [はじめに](/ja/onboarding/) — plugin の install、tracker profile の選択、最初の Issue を file する。
- [Concept](/ja/concept/tracker-profile/) — tracker profile、agent の責務、PR ライフサイクル、code review プロセス。
- [Policies](/ja/policies/issue-format/) — `/refine` と `/review` が照合する rule (Issue format、size、SP、priority、DoD)。
- [Commands](/ja/commands/refine/) — `/refine`, `/breakdown`, `/develop`, `/review` をライフサイクル順に。

## AI 契約はどこにあるか

soloscrum の AI agent 向けの振る舞いの正本は、**このサイトではなく** [リポジトリ](https://github.com/mew-ton/soloscrum) 側にあります — `skills/`, `agents/`, `commands/`, `CLAUDE.md` が契約そのものです。このサイトは人間向けのコンパニオン: 手書きのオリエンテーション、概念解説、command のウォークスルーを置きます。2 つの面は意図的に独立に保たれています — spec ファイルは AI 消費向けに、こちらのページは人間が頭から読むために書かれています。
