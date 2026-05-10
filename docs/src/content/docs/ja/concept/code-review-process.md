---
title: code review プロセス
description: "`/review` が CodeRabbit と multi-agent review pipeline をどう組み合わせるか、なぜ severity が情報的なものに留まるか、そして各 finding が 3 つの verdict のいずれにどう辿り着くか。"
sidebar:
  order: 4
---

`/review` は 2 つの reviewer を並列で実行し、出力を 1 つの PR コメントにまとめます。2 つの reviewer は異なる理由で存在します — 一方は調整された外部ツール、もう一方は新鮮な agent のパネル — そして失敗の仕方が異なるため、扱いも異なります。どちらのソースから来た finding も、最終的に 2 つの結末のいずれかに辿り着きます: **fix する** か、**理由を述べて skip する** か。「severity が低いから無視する」という第 3 のパスは存在しません; それがこの設計が防ぐために存在する failure mode です。

## 2 つの review ソース

**CodeRabbit** は `coderabbit review --plain --base main` で起動します。`critical` / `major` / `minor` / `nitpick` のタグ付きで finding を生成します。これらのタグは情報的です — どんな種類の issue かを表すもので、skip するかどうかを表すものではありません。in-scope で正しい `nitpick` も依然として fix する価値があります。

**multi-agent review** は `code-review:code-review` slash command で起動します。この command は複数の Sonnet agent を並列で起動し、それぞれが特定のレンズ (security、architecture、bug scan、history、in-file ルール、coverage gap) を担当します。別の Haiku agent が各 finding を 0–100 でスコアします。0–100 は新鮮な agent のノイズパターンに合わせて校正されており、これらの agent は実際には機能していない制約を発明したり、ルールを誤引用したりする傾向があります。

両ソースの finding は、最下部の単一の verdict 行とともに、1 つの PR コメントにまとめられます。

## なぜ 2 つの閾値が存在するか

2 つのソースは異なる失敗の仕方をするため、異なるフィルタが必要です:

- **CodeRabbit の finding はすでにツールによってフィルタされている。** その severity 分類は情報的であり、最も低いティアであっても文書化されたパターンに対応します。severity で再フィルタすると正当なシグナルを静かに捨てることになります — それがまさにこの設計が防ぐために作られた failure です。
- **multi-agent reviewer は PR ごとに新鮮にスポーンする。** 制約を hallucinate したり、意図的な変更を flag したりしがちです。80 confidence の事前フィルタはそのために校正されたノイズゲートです。

事前フィルタ (multi-agent 側のみ適用) の後、生き残ったすべての finding は同じ per-item 決定を経ます。

2 つを混ぜること — agent の confidence フィルタを CodeRabbit に適用したり、「もっともらしく見える」からと 80 未満の agent finding を受け入れたり — は名前のついた anti-pattern です。

## per-item 決定

決定ステップに到達した finding ごとに、reviewer は **fix** か **理由を述べて skip** のいずれかを選択します。

次の 3 つすべてが真のとき **fix** します:

1. finding が **in-scope** — この PR の diff によって導入または直接変更されたコードまたは振る舞いに触れている。
2. 提案が正しい — 実際の issue を識別しており、提案された変更でそれに対処できる。
3. fix が **境界が明確** — PR がすでに触れたファイル (または些細に隣接するファイル) 内で、無関係なリファクタにカスケードすることなく適用できる。

これら 3 つが成立しコストが小さければ、`nitpick` でも fix すべきです。

次のいずれかが真のとき **理由を述べて skip** します:

- Out of scope — follow-up Issue として記録し、issue 番号を skip ノートに書く。
- 提案が間違っている、または diff の誤読に基づいている (具体的な誤読を引用する)。
- 明示的なプロジェクト規約と衝突する (どの規約か引用する)。

**有効ではない** skip 理由:

- 「nitpick だから」/「minor severity だから」 — severity は skip 理由ではありません。
- 具体的な議論なしの「solo dev だから skip」 — solo-dev によってこの finding が **なぜ** 該当しないかを説明してください。
- tracking link なしの「あとで fix する」 — Issue に変換して参照してください。

## draft-window の override

`code-review:code-review` command には、draft 状態の PR をスキップする eligibility check が同梱されています。soloscrum 内では、この check は **bypass** しなければなりません。`/review` が動くとき PR は意図的に draft であり、[draft window](/ja/concept/pr-lifecycle/) こそがローカル品質ゲートが発火する場所です。upstream の skip を尊重すると、review pipeline の半分を静かに捨てることになります。

`code-review:code-review` が明示的な override 引数を公開した場合は、それを優先してください。それまでは、soloscrum の review は draft PR を意図的に eligible として扱います。

## verdict

3 つの verdict が可能です。選択は、reviewer が diff 全体についてどう感じるかではなく、surface された finding に何が起こったかによって完全に決定されます:

- **Pass** — surface されたすべての finding が fix と決定され、その fix がこの PR に着地している (または finding がなかった)。
- **Pass with follow-ups** — すべての finding が決定されたが、1 つ以上が *out of scope として* skip され、別の follow-up Issue として記録された。PR は merge 可能、follow-up が存在する。
- **Fail** — 少なくとも 1 つの finding が、fix されておらず正当に out of scope でもない、本物の正確性 / セキュリティ / DoD 違反を識別している。

両ソースが決定すべき finding を 0 件しか生成しなかった場合 (CodeRabbit が "No findings ✔" で 80 以上スコアの agent finding がない場合)、代わりに canonical な「No issues found」コメントが投稿されます。

## verdict 後の流れ

verdict 後のアクションの詳細は [PR ライフサイクル概念](/ja/concept/pr-lifecycle/) で説明されますが、短いバージョン:

| Verdict | 次のアクション |
|---|---|
| Pass | approve → subtask `→ done` → CI green を待つ → `gh pr ready` → merge command を提示 |
| Pass with follow-ups | follow-up Issue があることを確認 → Pass と同じ |
| Fail | フィードバックを投稿 → subtask `→ in-progress` → PR を draft のまま |

知っておく価値のある 2 つの細部:

- `gh pr review --approve` は solo-dev では「Can not approve your own pull request」で失敗することが期待されています。これは verdict の変更ではありません — verdict コメントが正式な Pass の記録であり、残りのシーケンスはそのまま実行されます。
- `→ done` と `gh pr ready` の間の CI green 待機は Pass 契約の一部です。check が red になれば、Pass は遡及的に Fail に降格されます; red check で ready PR を昇格させることが、このステップが防ぐために存在する failure mode です。

## 関連項目

- 正本の契約 — PR コメントテンプレート、severity 表、完全な anti-pattern リストを含む — は [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md) にあります。
- verdict が PR の状態機械をどう駆動するかについては、[PR ライフサイクル概念](/ja/concept/pr-lifecycle/) を参照。
