---
title: soloscrum — Claude agent と回す solo dev のスクラムループ
description: 個人開発者が refine → breakdown → develop → review のスクラム的ループを AI agent と一緒に最後まで回せる Claude Code plugin。
---

**soloscrum は、個人開発者が AI agent と一緒にスクラム的な開発ループを回すための Claude Code plugin フレームワークです。**

## 解こうとしている問題

ひとりでプロジェクトを進める solo dev は、結局すべての役割を兼任することになります。アイデアを整理する、Issue を file する、分解する、実装する、レビューする、いつ ship するかを決める。役割を切り替えるたびに集中力が削られ、品質を担保するための工程 — review ゲート、DoD チェック、「この Issue はそもそも well-formed か」を確認するパス — は、ひとりしかいない部屋で真っ先にスキップされてしまいます。

soloscrum の賭けは、**役割ごとに十分厳格な契約を framework 側で用意すれば、Claude agent にその役割を任せられる**というものです。誰も見ていない状態でもループが正直に回り続けるための歯止め、それが契約の役割です。

## 構成要素

soloscrum は 4 つのパーツでできています:

- **skills** — framework が契約として読み込む機械可読な仕様 (共通定義の `-define-*`、tracker profile 固有の `-tracker-*`、operation 単位の skill)。リポジトリの `skills/` 配下に置かれます。
- **agents** — 5 つのロール定義: `soloscrum-po` (Product Owner)、`soloscrum-design` (Design)、`soloscrum-dev` (Dev)、`soloscrum-ui` (UI)、`soloscrum-review` (Review)。各 agent は自分が所有する概念だけを mutate します。
- **commands** — ユーザが直接叩くエントリポイント: `/refine`、`/breakdown`、`/develop`、`/review`。
- **tracker profile** — `github-only` (デフォルト) または `linear+github`。Subtask / SP / state の保存先を決めます。残りの framework は profile 非依存です。詳細は [tracker profile](/ja/concept/tracker-profile/) を参照してください。

## ワークフロー

```text
/refine     → アイデアを Background / Goal / AC / Out of Scope を備えた GitHub Issue にする
/breakdown  → サイズ閾値を超えた Issue を Sub-issue に分割する
/develop    → branch を切り、実装し、`Closes #N` を含む draft PR を開く
/review     → DoD + AC + CodeRabbit + multi-agent review → verdict → ready 引き渡し
```

最後の `gh pr merge` はユーザが実行します。irreversible なので、人間側に残してある唯一の手動ステップです。それ以前のステップ (PR 作成、verdict 投稿、draft → ready 昇格、state 遷移) はすべて reversible で、command の中で自律的に走ります。

## Fit / not-fit

次のような状況なら soloscrum が fit します:

- **solo developer** である (あるいは実質ひとりで回している — 変更ごとに人間 reviewer がせいぜい 1 人)。
- ワークフローの中心が **Claude Code** にあって、明示的な契約のもとなら自律的に動作させても構わない。
- 作業が **GitHub Issue + PR** で流れている (breakdown レイヤーに Linear を追加するのも可)。
- 「気が向いたときに review してもらう」ではなく、**PR ごとに必ず品質ゲートを通す** ことを望んでいる。

次のような状況なら fit しません:

- merge 前に **複数の人間 reviewer による approve** が必須要件として求められる。
- **複数の AI agent 間での移植性** が必要 — soloscrum は Claude Code plugin であることを前提に組まれています。
- 主目的が人を組織化するためのプロセスフレームワーク。soloscrum はあくまで agent 向けの契約をコード化したものです。

## 次のステップ

- [はじめに](/ja/onboarding/) — plugin の install、tracker profile の選択、最初の Issue を file するところまで。
- [Concept](/ja/concept/tracker-profile/) — tracker profile、agent の責務、PR ライフサイクル、code review プロセス。
- [Policies](/ja/policies/issue-format/) — `/refine` と `/review` が照合するルール (Issue format、size、SP、priority、DoD)。
- [Commands](/ja/commands/refine/) — `/refine` / `/breakdown` / `/develop` / `/review` をライフサイクル順に解説。

## AI 契約はどこにあるか

soloscrum の AI agent 向けの振る舞いを定めた正本は、**このサイトではなく** [リポジトリ](https://github.com/mew-ton/soloscrum) 側にあります。`skills/`、`agents/`、`commands/`、`CLAUDE.md` が契約そのものです。このサイトは人間向けのコンパニオンで、手書きのオリエンテーション、概念の解説、command のウォークスルーを載せています。2 つの面は意図的に独立に保ってあって、spec ファイルは AI 向けに、このページは人間が頭から読み下すために書かれています。
