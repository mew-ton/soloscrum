---
title: tracker profile
description: Issue / subtask / SP / state / 依存関係をどこに保存するかを soloscrum がどう決めるか — そして各 command が選択を埋め込まずに正しい tracker をどう選ぶか。
sidebar:
  order: 1
---

soloscrum は issue tracker の上で動きます。チームによって使う tracker は異なり、「すべて GitHub に置く」または「すべて Linear に置く」と決め打ちしたフレームワークは、その前提が崩れた瞬間に fork するしかなくなります。soloscrum はその fork を回避するため、tracker を差し替え可能なレイヤーとして扱い、すべての command の冒頭で **tracker profile** を解決します。

tracker profile は小さな決定の束です: 親 Issue がどこにあるか、subtask がどこにあるか、issue ID がどう見えるか、SP をどこに記録するか、状態機械を tracker のネイティブな state にどうマッピングするか、そして agent がそれらを読み書きするためにどの API を使うか。本日時点で 2 つの profile が提供されており、フレームワーク残部は意図的に profile 非依存になっています。

## 2 つの profile

**`github-only`** は保守的なデフォルトです。Issue は GitHub Issues、subtask はネイティブの GH Sub-issue、SP は GitHub Projects v2 の Number フィールドに置かれ、state は `state:in-progress` / `state:in-review` / `state:done` ラベルとして表現され、依存関係は Issue 本文の `Depends on: #N` 行として書かれて GitHub にクロスリンクとしてレンダリングされます。Linear が使えないリポジトリ — 公開 OSS プロジェクト、GitHub-only 制約のある組織、単に 2 つ目のツールをループに入れたくない人 — で機能します。

**`linear+github`** は、すでに Linear を運用しているチームのための選択です。親 Issue は GitHub に残り（commit / PR / `Closes #` キーワードを動かし続けるためにこちらが正本）、subtask、SP、state、依存関係は Linear に置かれ、Linear のネイティブな GitHub 同期で到達します。この profile での subtask ID は `#123` ではなく `PRJ-42` のように見えます。priority ラベルは GitHub に残ります — 親については GitHub が正本だからです。

## profile はどう解決されるか

tracker に触れる必要があるすべての command と agent は同じ解決順序を辿ります:

1. `.claude/rules/tracker.md` のリポジトリレベル override — `profile:` frontmatter を持つファイルがあれば、それが勝ちます。
2. plugin インストール時のプロンプトで設定されたユーザレベル設定 (`.claude/settings.json` の `tracker_profile`)。
3. ビルトインデフォルト `github-only`。

解決は最初のマッチで停止します。1 つのリポジトリだけを特定の profile に固定し、その他はユーザレベルのデフォルトを保つ — これが override の存在理由です。これがないと、Claude のインストールを共有する 2 つのリポジトリが同じ tracker を共有することになり、それは大抵望ましくありません。

## なぜフレームワークは profile 非依存に保たれるのか

ライフサイクル、状態機械、DoD、review pipeline は、決して「Linear」や「GitHub」を名指ししません。代わりに、tracker と話す必要があるものはすべて、profile で名前空間化された **operation skill** に委譲します: `soloscrum-tracker-{github|linear}-{operation}`。profile を解決することは prefix を選ぶことと同じであり、そこから先は agent がマッチする `create-subtask`, `transition-state`, `set-sp`, `query-state`, `query-backlog`, `add-dependency` skill を呼び出し、データの保存場所に関わらず operation は同じように動きます。

これが、`/develop` フローを GitHub-only な OSS リポジトリでも、Linear を使うプロダクトチームでも同じに見せる理由です: 動詞は同じで、storage backend だけが異なります。

## `.claude/rules/tracker.md` をいつ設定するか

ユーザレベルのデフォルトがそのリポジトリに対して間違っているとき、override に手を伸ばします。よくある 2 つのケース:

- グローバルに `linear+github` を設定したユーザが、Linear ワークスペースのない公開 OSS リポジトリを clone する。command がそのユーザに存在しない Linear team に到達しようとしないよう、そのリポジトリを `github-only` に固定します。
- デフォルトを `github-only` にしたユーザが、Linear を使うプロジェクトに参加する。subtask が GitHub 上で見えなくなるのではなく、チームの Linear board に着地するよう、そのリポジトリを `linear+github` に固定します。

override ファイルは意図的にミニマルです:

```markdown
---
profile: github-only
---
```

その 1 つの frontmatter フィールドが契約のすべてです。

## 関連項目

- 完全な storage 行列と operation skill 表は正本の契約にあります: [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md) を参照。
- skill ごとの全 tracker operation のサマリは、[tracker operations リファレンス](/reference/tracker-operations/) へ。
- profile 解決の簡潔な spec ビューは、[tracker profile リファレンス](/reference/define-tracker-profile/) を参照。
