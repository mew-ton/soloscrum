---
title: tracker profile
description: Issue / subtask / SP / state / dependency をどこに保存し、各 command がどのトラッカーを使うかを決める仕組みを説明します。
sidebar:
  order: 1
---

**tracker profile** は、各 command が読み書きする issue tracker を選択する仕組みです。soloscrum はすべての command の冒頭で profile を解決し、フレームワーク本体は profile に依存しない形に保たれています。

profile は次の項目をまとめて決めます。

- 親 Issue をどこに置くか
- subtask をどこに置くか
- issue ID のフォーマット
- SP をどこに記録するか
- state machine をトラッカーのネイティブ state にどう対応させるか
- agent が使う API

現時点で 2 種類の profile が用意されています。

## 2 つの profile

### `github-only` (default)

- Issue は GitHub Issue
- subtask は GH ネイティブの Sub-issue
- SP は GitHub Projects v2 の Number field に保存
- state は `state:in-progress` / `state:in-review` / `state:done` のラベルで表現
- 依存関係は Issue 本文の `Depends on: #N` 行 (GitHub が自動的に相互リンクをレンダリング)

Linear が利用できない環境 — 公開 OSS、GitHub のみを許可する組織、単一ツールで完結したいワークフローなど — で使います。

### `linear+github`

- 親 Issue は GitHub に残します (commit / PR / `Closes #` の挙動を維持するため)
- subtask / SP / state / 依存関係は Linear 側に置き、Linear のネイティブな GitHub 連携で同期します
- subtask ID は `#123` ではなく `PRJ-42` のような形式
- priority ラベルは GitHub 側に残ります (親 Issue のメタデータは GitHub を canonical とする方針のため)

すでに Linear を運用しているチームで使います。

## 解決順序

tracker を扱う command や agent は、次の順で profile を探し、最初にマッチしたものを採用します。

1. リポジトリレベルのオーバーライド: `.claude/rules/tracker.md` の frontmatter `profile:`
2. ユーザレベルの設定: plugin のインストール時に保存された `.claude/settings.json` の `tracker_profile`
3. 組み込みデフォルト: `github-only`

リポジトリレベルのオーバーライドにより、ユーザ全体のデフォルトを変えずに 1 つのリポジトリだけを別 profile に固定できます。

## フレームワーク本体が profile に依存しない理由

ライフサイクル / state machine / DoD / review pipeline のいずれにも「Linear」や「GitHub」という固有名は登場しません。tracker に触れる処理はすべて、profile ごとに用意された **operation skill** に委譲します。命名は `soloscrum-tracker-{github|linear}-{operation}` という形式で、profile が prefix を決め、`create-subtask` / `transition-state` / `set-sp` / `query-state` / `query-backlog` / `add-dependency` のいずれかを呼び出します。

この設計により、GitHub のみの OSS リポジトリと Linear を併用するプロダクトチームで、`/develop` の動作は完全に同じです。動詞は共通で、ストレージだけが切り替わります。

## `.claude/rules/tracker.md` を置くべき場面

ユーザレベルのデフォルトがそのリポジトリに合わない場合に使います。典型例は次の 2 つです。

- グローバルで `linear+github` を使っているが、Linear workspace が存在しない公開 OSS リポジトリに参加する → `github-only` に固定
- グローバルでは `github-only` を使っているが、Linear で管理されているプロジェクトに参加する → `linear+github` に固定し、subtask がチームの Linear ボードに作成されるようにする

オーバーライドファイルは frontmatter 1 行だけで完結します。

```markdown
---
profile: github-only
---
```

## 参考

- 詳細なストレージ対応表と operation skill 一覧: [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md)
