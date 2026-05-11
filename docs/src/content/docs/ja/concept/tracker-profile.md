---
title: tracker profile
description: Issue / subtask / SP / state / 依存関係をどこに保存するか。soloscrum が tracker の選択をハードコードせず、command ごとに解決する仕組み。
sidebar:
  order: 1
---

soloscrum は issue tracker の上で動く。チームによって使う tracker は異なるため、「すべて GitHub に置く」や「すべて Linear に置く」と決め打ちしたフレームワークは、前提が崩れた瞬間に fork するしかなくなる。それを避けるため、soloscrum は tracker を差し替え可能なレイヤーとして扱い、command の冒頭で **tracker profile** を解決する。

tracker profile は小さな決定の束だ。親 Issue の保管場所、subtask の保管場所、issue ID の形、SP の記録先、state machine と tracker ネイティブ state のマッピング、そして読み書きに使う API。今のところ profile は 2 つで、その外側のフレームワークは意図的に profile 非依存に保ってある。

## 2 つの profile

**`github-only`** は保守的なデフォルトだ。Issue は GitHub Issue、subtask はネイティブの GH Sub-issue、SP は GitHub Projects v2 の Number フィールド、state は `state:in-progress` / `state:in-review` / `state:done` ラベルで表現し、依存関係は Issue 本文に `Depends on: #N` の行として書く（GitHub がクロスリンクとしてレンダリングしてくれる）。Linear を使えないリポジトリ — 公開 OSS プロジェクト、GitHub-only 制約のある組織、単に二つ目のツールを増やしたくない人 — はこの profile で完結する。

**`linear+github`** は、すでに Linear を運用しているチーム向けだ。親 Issue は GitHub に残す（commit / PR / `Closes #` キーワードを機能させ続けるため、ここが正本）。一方で subtask、SP、state、依存関係は Linear 側に置き、Linear ネイティブの GitHub 同期で繋ぐ。この profile での subtask ID は `#123` ではなく `PRJ-42` の形になる。priority ラベルだけは引き続き GitHub に置く — 親については GitHub が正本だからだ。

## profile の解決順序

tracker に触れる command や agent は、毎回この順序で解決する:

1. `.claude/rules/tracker.md` のリポジトリ override — `profile:` frontmatter を持つファイルが存在すれば最優先
2. plugin インストール時のプロンプトで決めたユーザレベル設定（`.claude/settings.json` の `tracker_profile`）
3. ビルトインデフォルトの `github-only`

最初にマッチしたものを採用し、そこで打ち切る。1 リポジトリだけを特定の profile に固定しつつ、他のリポジトリではユーザレベルのデフォルトを残したい — override が存在するのはこのケースのためで、これがないと Claude のインストールを共有する複数リポジトリが同じ tracker を共有してしまう。

## なぜフレームワーク本体は profile 非依存なのか

ライフサイクル、state machine、DoD、review pipeline — どこにも「Linear」や「GitHub」という名前は出てこない。代わりに、tracker と話す処理はすべて profile 名前空間付きの **operation skill** に委譲する: `soloscrum-tracker-{github|linear}-{operation}` の形だ。profile を解決することは prefix を選ぶことと等価で、あとは `create-subtask` / `transition-state` / `set-sp` / `query-state` / `query-backlog` / `add-dependency` といった skill を呼ぶだけで、データの保管場所に関わらず同じ operation が動く。

おかげで `/develop` の流れは、GitHub-only な OSS リポジトリでも Linear を使うプロダクトチームでも同じ見た目になる。動詞は共通で、変わるのは backend だけだ。

## `.claude/rules/tracker.md` をいつ書くか

ユーザレベルのデフォルトがこのリポジトリには合わないとき、override に手を伸ばす。よくあるのは次の 2 ケースだ:

- ユーザがグローバルに `linear+github` を設定していて、Linear ワークスペースを持たない公開 OSS リポジトリを clone した。command が存在しない Linear team に接続しようとしないよう、そのリポジトリを `github-only` に固定する。
- 逆にデフォルトが `github-only` のユーザが、Linear を使うプロジェクトに参加した。subtask が GitHub 上で見えないままにならず、チームの Linear ボードに着地するように、そのリポジトリを `linear+github` に固定する。

override ファイルはミニマルだ:

```markdown
---
profile: github-only
---
```

この frontmatter 1 行が契約のすべてだ。

## 関連項目

- ストレージの完全な対応表と operation skill の一覧は、正本の契約を参照: [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md)。
