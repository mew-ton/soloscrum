---
title: "/soloscrum:collect-perspective"
description: 他人の PR のレビューコメントや、いま進行中の会話から再利用可能なレビュー観点を抽出し、/soloscrum:review が選んで使える形でマシンローカルに保存します。
sidebar:
  order: 6
---

レビューの知見は放っておくと消えます。壁打ちで問題を詰めている最中や、他人のレビューを読んでいる最中に立ち上がって、セッションが終われば失われる。[`/soloscrum:review`](/ja/commands/review/) は毎回ゼロから同じ観点を導き直すので、一度払ったコストが次のレビューに引き継がれません。

`/soloscrum:collect-perspective` はその知見を残すためのコマンドです。

## 使い方

```bash
/soloscrum:collect-perspective https://github.com/other-org/other-repo/pull/123
/soloscrum:collect-perspective
```

PR URL を渡せばその PR のレビューコメントが、引数なしならいま進行中の会話がソースになります。

**他人の**プロジェクトのレビューは特に良いソースです。著者の文脈を持たない読み手に向けて理由が明示的に書かれており、それはそのまま再利用可能な観点が必要とする形だからです。

## 何が作られるか

**レビュー観点** — 何を見るべきかについての再利用可能な判断 1 件 — が次の場所に保存されます。

```text
~/.claude/review-perspectives/<name>/PERSPECTIVE.md
```

リポジトリの外、マシンローカルで、扱う全プロジェクトから共通で参照されます。soloscrum は個人開発者向けのフレームワークなので、永続する単位はプロジェクトの規約ではなく**個人が蓄積した判断**です。

frontmatter は skill と同型（`name` と `description`）ですが、観点は意図的に `~/.claude/skills/` には置きません。skill はあらゆる会話で発火を競いますが、観点はそうであってはならない — 特定の消費者が、特定の瞬間に、意図して読みに行く受動的な資産だからです。

## 手順

1. PR のレビューコメント、または会話から**収集**する。
2. 別の変更でも成り立つ記述だけを**抽出**する。その diff 固有の事実を述べているだけのものは落とす。
3. 元のケースを超えて**一般化**する — ファイルではなくフレームワーク、個別事象ではなくミスの類型。具体例は本文に移す。
4. 既存の観点の description を全件読んで**突き合わせる**。重複する候補は新規ではなく**更新**にする。トリガが重なった観点は選択側に推測を強い、両方発火するか片方も発火しないかのどちらかになります。
5. **1 回だけ確認**を取り、書き込む。

## なぜ確認するのか

このコマンドはリポジトリの外、ホームディレクトリに書き込みます。soloscrum の自律性契約はリポジトリの状態と PR を対象としており、マシンを書き換える権限はそこに含まれません。さらに観点のコーパスは個人的で寿命が長く、誤った 1 件が以後すべてのレビューを静かに劣化させます。

そのため、生成される内容を全文提示したうえで、**呼び出しごとに 1 回**（ファイルごとではなく）確認を取ります。更新の場合は差分を提示します — すでに承認済みのものへの変更を承認してもらう形になるためです。

利用者自身の `~/.claude/settings.json` に `Write(~/.claude/review-perspectives/**)` を足せばハーネス側の確認は減らせます。上記の確認は soloscrum 自身のゲートなので残ります。

## 機能する description の書き方

`/soloscrum:review` は **description だけ**を読んで観点を選びます。description は要約ではなく発火条件そのもので、制約はそこから来ています。

- **英語で書く。** レビューを何語で行うかに関わらず、description 同士の比較が一貫するため。
- **2048 文字以内。** description は全件まとめて読まれるので、1 件の長さは毎回の選択が払うコストになります。
- **when と what を書く。** さらに negative trigger（適用しないケース）を強く推奨します。境界の書かれていない観点はすべてに一致し、そればかりのコーパスは観点が無いのと同じです。
- **本文を読まずに判断できること。** 本文を読まないと関連性が分からない description は、唯一の役割を果たせていません。

良い例・悪い例を含む完全な契約は [`skills/soloscrum-define-review-perspective`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-review-perspective/SKILL.md) にあります。

## Output

観点ごとに、新規作成か更新か、パス、description。加えて、一般化できず捨てた候補も提示します — 捨てた分こそ、利用者が「拾われたはず」と誤解しうる部分だからです。

## 関連

- [`/soloscrum:review`](/ja/commands/review/) — コーパスから選んで適用する側
- [コードレビュープロセス](/ja/concept/code-review-process/) — 観点由来の findings がパイプラインのどこに入るか
- 正典: [`commands/collect-perspective.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/collect-perspective.md)
