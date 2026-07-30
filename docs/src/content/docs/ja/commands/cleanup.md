---
title: "/soloscrum:cleanup"
description: マージ済みブランチの git worktree を回収し、残したものはその理由とともに報告します。マージ判定は PR の状態を主、ブランチの祖先関係を副として機械的に行います。
sidebar:
  order: 5
---

`/soloscrum:cleanup` は [`/soloscrum:develop`](/ja/commands/develop/) が作った git worktree を、その中の作業がマージされたあとに回収します。work unit ごとに worktree を持つモデルのもう半分です — `/soloscrum:develop` がブランチ 1 本につき 1 つの worktree を作ることでメインのチェックアウトが feature ブランチに切り替わらないようにし、`/soloscrum:cleanup` が不要になった worktree を片付けます。

## 使い方

```bash
/soloscrum:cleanup
/soloscrum:cleanup --dry-run
```

`--dry-run` は回収対象を報告するだけで、何も削除しません。

## ここでの「マージ済み」の判定

判定は機械的で、次の 2 つを順に試します。

1. **PR の状態。** `gh pr list --head <branch> --state merged` がそのブランチのマージ済み PR を返す。
2. **ブランチの祖先関係。** そのブランチが `origin/<default>` の祖先である。

PR 判定を先に置くのは、それが **squash merge** でも成立する唯一の判定だからです。squash はコミットを書き換えるため、その後ブランチの tip はデフォルトブランチの祖先ではなくなります。祖先判定だけに頼ると、実際には出荷済みの作業を「未マージ」と報告し、永久に回収されません。祖先判定も無駄ではなく、PR を経ずにマージされたブランチや、`gh` が使えない環境をカバーします。

## 触らないもの

次のいずれかに当てはまる worktree は、**削除せず報告だけ**します。

- 未コミットの変更がある（untracked ファイルを含む）
- detached HEAD で、判定すべきブランチがない
- マージ済み PR は存在するが、ローカルのブランチ tip がその PR のマージ対象コミットと一致しない — push されないままローカルにコミットが積まれている状態

これらは要約せず、理由をそのまま提示します。どうするかを決められるのは利用者だけだからです。

削除自体には `git worktree remove` と `git branch -d` を使います。これらは dirty な worktree と未マージのブランチを**拒否する**形式です。その拒否が上のチェックの背後にある独立した二重の防護になります。強制版（`--force` / `-D`）はそれを無効化するため、使いません。

## 自律性

回収は確認を取らずに実行します。マージ判定と安全条件の両方を通った worktree は、デフォルトブランチかマージ済み PR のどちらかにすでに存在するものしか持っていないため、削除しても作業は失われません。

復旧経路はその 2 か所であって、**remote ブランチではありません**。`gh pr merge --delete-branch` は remote ref を消しますし、squash merge では元のブランチ tip はデフォルトブランチの祖先ですらありません。残るのはマージされた内容そのもの — デフォルトブランチ上と、PR の記録の中です。

## 実行されるタイミング

| きっかけ | 挙動 |
|---|---|
| 利用者が直接呼ぶ | 通常の回収パス |
| `/soloscrum:develop` の開始時 | 同じ回収パス。worktree 置き場が work unit をまたいで溜まらないようにする |
| `/soloscrum:review` の Pass 後 | merge コマンドと並べて**提示するだけ**で、実行はしない。verdict の時点では PR は未マージなので、直前の worktree はまだ進行中であるのが正しい |

## Output

worktree ごとに、ブランチ / パス / action（`removed` / `kept` / `skipped`、`--dry-run` では `would-remove`）/ 理由。加えて、回収した数・進行中の数・利用者の判断が要る数の 1 行サマリ。

worktree 置き場が空なら「回収対象なし」と報告します。エラーではありません。

## 関連

- [`/soloscrum:develop`](/ja/commands/develop/) — このコマンドが回収する worktree を作る側
- 正典: [`commands/cleanup.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/cleanup.md) と [`skills/soloscrum-define-worktree`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-worktree/SKILL.md)
