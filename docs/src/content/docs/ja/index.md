---
title: soloscrum docs
description: soloscrum フレームワークの人間向けコンパニオンドキュメント。
---

このサイトは [soloscrum](https://github.com/mew-ton/soloscrum) フレームワークに対する **人間向けのコンパニオン** です。オンボーディングノート、概念解説、command のウォークスルー、人間が能動的に使う / 判断する policies といった、人間に向けた手書きの説明を集める場であり、フレームワークの機械可読な spec ファイルとは独立して書かれます。

初めてなら [はじめに](/onboarding/) から開始してください — `/plugin install` から最初の Issue を `/refine` で file するまでをガイドします。そこから:

- [Concept](/concept/tracker-profile/) は why を解説 (tracker profile、agent の責務、PR ライフサイクル、code review プロセス)。
- [Policies](/policies/issue-format/) は `/refine` と `/review` が照合する 5 つの rule を扱います。
- [Commands](/commands/refine/) は `/refine`, `/breakdown`, `/develop`, `/review` をライフサイクル順にウォークスルーします。

## AI 契約はどこにあるか

soloscrum の AI agent 向けの振る舞いは、**このサイトではなく** リポジトリ本体に置かれています:

- `skills/` — skill 仕様（すべての command と agent が読む契約）
- `agents/` — agent ロール定義
- `commands/` — `/refine`, `/breakdown`, `/develop`, `/review` の command 仕様
- `CLAUDE.md` — リポジトリレベルの指示

このドキュメントサイトは上記ファイルを **参照** しますが、import や変換はしません。2 つの面は意図的に独立に保たれています: spec ファイルは AI 消費向けにチューニングされていて、こちらのページは人間が頭から読むために書かれています。
