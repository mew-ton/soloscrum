---
title: soloscrum docs (作成中)
description: soloscrum フレームワークの人間向けコンパニオンドキュメント。
---

このサイトは [soloscrum](https://github.com/mew-ton/soloscrum) フレームワークに対する **人間向けのコンパニオン** です。オンボーディングノート、概念解説、command のウォークスルー、リファレンス資料といった、人間に向けた手書きの説明を集める場であり、フレームワークの機械可読な spec ファイルとは独立して書かれます。

サイトは現在スタブ状態です。Concept / Reference / Commands / Onboarding の各セクションは、後続の subtask で追加される予定です（[#47](https://github.com/mew-ton/soloscrum/issues/47) と [#48](https://github.com/mew-ton/soloscrum/issues/48) を参照）。

## AI 契約はどこにあるか

soloscrum の AI agent 向けの振る舞いは、**このサイトではなく** リポジトリ本体に置かれています:

- `skills/` — skill 仕様（すべての command と agent が読む契約）
- `agents/` — agent ロール定義
- `commands/` — `/refine`, `/breakdown`, `/develop`, `/review` の command 仕様
- `CLAUDE.md` — リポジトリレベルの指示

このドキュメントサイトは上記ファイルを **参照** しますが、import や変換はしません。2 つの面は意図的に独立に保たれています: spec ファイルは AI 消費向けにチューニングされていて、こちらのページは人間が頭から読むために書かれています。
