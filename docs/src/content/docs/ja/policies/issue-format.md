---
title: Issue フォーマット
description: soloscrum の Issue は intent（目的・成功条件）を残す永続的な記録です。親 Issue は 4 セクション本文、Subtask は軽量な作業本文を使い、どちらに該当するかは 2 条件の判別で決まります。
sidebar:
  order: 1
---

soloscrum の Issue は **intent（目的・成功条件・スコープ境界）を残す永続的な記録**です。PR・commit・後の意思決定から参照される一方、実行手順・進捗・証跡を入れる容れ物ではありません。それらは PR・commit・branch・CI 実行結果・tracker ラベル側に置かれます。

タイトルの「How を書かない」ルールも、AC の「実装ではなく outcome を書く」ルールも、ここから直に導かれます。スタイルの好みではありません。

## Issue と Subtask

階層は 2 つあります。親 **Issue** は intent（why・成功条件・スコープ境界）を持ちます。**Subtask** はその intent を届けるための作業スライスを持ちます。本文の形式も別物です。

ある作業項目を独立した Issue として立てるかどうかは、次の **2 条件が両方成り立つか**で判定します。

1. **自己完結した、独立に検証可能な outcome を持つ。** 「done」を単独で判定できる。outcome はユーザー視点の挙動でも、構造的/契約的/能力的なマイルストーンでも構わない（例:「auth モジュールがこの契約を公開し、テストが通る」「署名済みリリース成果物がビルドから出る」）。
2. **既存の上位 intent の単なる配信スライスではない。** すでに登録済みの、または今 `/refine` 中の上位 intent が「why」を持っていて、候補がその一部を切り出しただけ、という関係になっていない。

どちらかが満たされなければ、その候補は親 intent の Subtask です。

この境界は**固定された属性ではなく、関係**で決まります。同じ作業でも、文脈が違えば Issue にも Subtask にもなります。リリース前で上位 intent が存在しなければ基盤的な作業もそれ自体が Issue になり、リリース後にユーザー向け機能という上位 intent が登場すれば同じ作業はその Subtask に降ります。リリース状態・プロジェクトの成熟度・周囲の intent ランドスケープが、条件 2 の通過可否を動かします。

## 4 つのセクション（Issue 本文）

親 Issue の本文は、常に次の順序で書きます。

```markdown
## Background
[Why this feature is needed.]

## Goal
[State the objective in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable outcome — Shape A or Shape B; see below.]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing.]

## Notes
[Supplementary info, references, design links.]
```

タイトルのルール:

- 動詞から始める
- 50 文字以内
- What を書く（How は書かない）

タイトルのルールは Subtask にも同じく適用されます（動詞始まり・How を書かない・50 文字以内）。

AC は次の 2 つの shape のいずれかを使います（Issue ごとに選ぶ）。

- **Shape A — ユーザー視点の挙動。** `user can log in with email` / `error message is shown on invalid input` のような形。プロダクト機能や、ユーザーが観測できる変化向け。
- **Shape B — 構造的・契約的・能力的な outcome。** `auth module exposes verify(token) returning {valid, expiry}` / `build pipeline produces a signed release artefact` のような形。基盤的・インフラ・リリース前の作業で、ユーザー surface がまだ存在しない場合や、outcome を契約や能力として表現する方が自然な場合に使います。

どちらの shape も「検証可能な状態」を書きます。「手順」ではありません。1 つの Issue が両方の surface にまたがる場合は、両形を混在させて構いません。

本文の先頭には `<!-- soloscrum-issue-format -->` の HTML コメント、末尾には小さなイタリック体のフッタが付きます。これにより janitor や `/validate` は、その Issue が soloscrum フォーマットで書かれているかどうかを軽く判定できます。

## Subtask 本文（作業）

Subtask は親 Issue の intent を届ける作業スライスです。Background / Goal / Acceptance Criteria / Out of Scope を**持ちません** — それらは親に属します。Subtask の本文は意図的に軽くします。

```markdown
Parent: #<parent-issue-number>

## What
[One sentence describing the slice — what part of the parent's intent this delivers.]

## Checklist
- [ ] [Concrete step toward the slice]
- [ ] [Another step]

## Notes
[Optional: design points, dependencies on other Subtasks, references.]
```

Subtask の done 条件は「このスライスが着地したことで親 intent が満たされる方向に進み、かつ退行がない」です。intent 単位の AC サインオフ自体は、最後の Subtask の PR がマージされたタイミングで**親 Issue 側で**行います。

## 適用される場面

- `/refine` は親 Issue を intent 本文の形で作成します
- `/breakdown` は Subtask を作業本文の軽量な形で作成します
- `/breakdown` を走らせる前に、`/validate` が既存 Issue が intent 本文の形になっているかを確認します
- Issue や Subtask を triage、見積もり、ピックアップする際の読み手側の前提でもあります

## 付属テンプレート

`templates/ISSUE_TEMPLATE.md` は 4 セクションの **intent 本文**を写したテンプレートです。Subtask はこのテンプレートを使いません — Subtask は `/breakdown` 経由で作られます。テンプレートの使い方は 2 通りあります。

- `.github/ISSUE_TEMPLATE/` 配下にコピーすれば、GitHub の「New Issue」UI でテンプレートの選択肢として表示されます
- GitHub web UI で新規 Issue を開き、本文に手動でペーストします

canonical な言語は英語です。多言語版は対象外です。

## 参考

- この形式で書かれた本文に対するサイズ上限: [`issue-size`](/ja/policies/issue-size/)
- canonical な契約: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md)
