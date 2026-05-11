---
title: code review プロセス
description: "`/review` が CodeRabbit と multi-agent review pipeline をどう組み合わせるか、severity が情報的に留まる理由、そして finding が 3 つの verdict のどこに行き着くか。"
sidebar:
  order: 4
---

`/review` は 2 つの reviewer を並列で走らせ、出力を 1 つの PR コメントにまとめる。reviewer が 2 つあるのには別々の理由があり、一方は調整済みの外部ツール、もう一方は新しく立ち上げた agent のパネルで、失敗の仕方が違うために扱いも違う。どちらのソースから来た finding も、最終的には 2 つの結末のどちらかに辿り着く: **修正する**、または **理由を述べて skip する**。「severity が低いから無視する」という第 3 の経路は存在しない — それこそが、この設計が防ぐために組まれた失敗モードだ。

## 2 つの review ソース

**CodeRabbit** は `coderabbit review --plain --base main` で起動する。`critical` / `major` / `minor` / `nitpick` のタグ付きで finding を返してくる。これらのタグは情報的なものだ — どういう種類の issue かを示すだけで、skip するかどうかとは別の話になる。in-scope で正しい `nitpick` も、依然として修正する価値がある。

**multi-agent review** は `code-review:code-review` slash command から起動する。複数の Sonnet agent を並列で立ち上げ、それぞれに専門レンズ (security、architecture、bug scan、history、in-file ルール、coverage gap) を担当させる。別途 Haiku agent が各 finding を 0–100 でスコアリングする。0–100 は新しく立ち上がった agent のノイズパターンに合わせて校正してあり、これらの agent は実在しない制約を発明したりルールを誤引用したりする傾向がある。

両ソースの finding は、最下部に verdict 行を 1 行添えて、1 つの PR コメントにまとめられる。

## なぜ 2 種類の閾値があるのか

2 つのソースは失敗の仕方が違うので、別々のフィルタが必要だ:

- **CodeRabbit の finding はツール側ですでにフィルタ済み。** severity 分類は情報的なものにすぎず、最下層であってもドキュメント化されたパターンに対応している。ここで再度 severity フィルタをかけると、正当なシグナルを黙って捨てることになる — まさにこの設計が防ぎたい失敗そのものだ。
- **multi-agent reviewer は PR ごとに新規に spawn する。** 制約を hallucinate したり、意図的な変更を flag したりしがちだ。80 confidence の事前フィルタは、そのノイズに合わせて校正したゲートだ。

事前フィルタを通過した後 (multi-agent 側にだけ適用される)、生き残った finding はすべて同じ per-item 決定にかかる。

2 つを混ぜること — つまり agent 用の confidence フィルタを CodeRabbit に適用したり、「もっともらしい」という理由で 80 未満の agent finding を採用したり — は名前のついた anti-pattern だ。

## per-item の決定

決定段階に届いた finding ごとに、reviewer は **修正する** か **理由を述べて skip する** かを選ぶ。

次の 3 つすべてが成立するとき **修正する**:

1. finding が **in-scope** である — この PR の diff で導入または直接変更したコード / 振る舞いに触れている。
2. 指摘が正しい — 実在する issue を特定しており、提案された変更でそれに対処できる。
3. fix が **境界の明確** — PR がすでに触れているファイル (またはごく隣接する範囲) で完結し、無関係なリファクタに波及しない。

この 3 つが揃ってコストが小さければ、`nitpick` であっても修正すべきだ。

次のいずれかに該当するとき **理由を述べて skip する**:

- out of scope — follow-up Issue として記録し、skip ノートにその issue 番号を残す。
- 指摘が間違っている、または diff の誤読に基づいている — どこを誤読したかを具体的に引用する。
- 明示的なプロジェクト規約と衝突する — どの規約かを引用する。

逆に **skip 理由として認められないもの**:

- 「nitpick だから」「minor severity だから」 — severity は skip 理由ではない。
- 具体的な根拠なしの「solo dev だから skip」 — solo-dev によってこの finding が「なぜ」該当しないのかを説明すること。
- tracking link のない「あとで修正する」 — Issue に変換して参照を残すこと。

## draft-window override

`code-review:code-review` command には、draft のままの PR をスキップする eligibility check が同梱されている。soloscrum の中では、このチェックを **bypass** する必要がある。`/review` が走る時点で PR が draft なのは意図的で、ローカル品質ゲートが発火する場所こそ [draft window](/ja/concept/pr-lifecycle/) だからだ。upstream の skip をそのまま尊重すると、review pipeline の半分を黙って捨ててしまう。

将来 `code-review:code-review` 側に明示的な override 引数が用意されたら、そちらを優先する。それまでは、soloscrum の review は draft PR を意図的に eligible 扱いにする。

## verdict

verdict は 3 種類ある。選択は完全に「surface された finding に何が起きたか」で決まり、reviewer が diff 全体に対して抱く印象とは無関係だ:

- **Pass** — surface された各 finding が「修正する」と決定され、その修正がこの PR に着地している (または finding が 0 件だった)。
- **Pass with follow-ups** — すべての finding が決定済みだが、1 つ以上が *out of scope として* skip され、別の follow-up Issue として記録されている。PR は merge 可能で、フォローアップは別途存在する。
- **Fail** — 少なくとも 1 つの finding が、修正もされておらず out of scope でもない、本物の correctness / セキュリティ / DoD 違反を指している。

両ソースが決定すべき finding を 0 件しか出さなかった場合 (CodeRabbit が "No findings ✔" を返し、かつ 80 以上スコアの agent finding がない場合)、代わりに canonical な「No issues found」コメントが投稿される。

## verdict 後の流れ

verdict 後のアクションの詳細は [PR ライフサイクル概念](/ja/concept/pr-lifecycle/) に譲るが、要点を短くまとめると:

| Verdict | 次のアクション |
|---|---|
| Pass | approve → subtask `→ done` → CI green を待つ → `gh pr ready` → merge command を提示 |
| Pass with follow-ups | follow-up Issue があることを確認 → Pass と同じ |
| Fail | フィードバックを投稿 → subtask `→ in-progress` → PR は draft のまま |

知っておきたい細部が 2 つある:

- `gh pr review --approve` は solo-dev では「Can not approve your own pull request」で失敗するのが想定どおりだ。これは verdict の変更ではなく — verdict コメントが正式な Pass の記録で、残りのシーケンスはそのまま走り抜ける。
- `→ done` と `gh pr ready` のあいだに挟まる「CI green を待つ」は Pass 契約の一部だ。check が red になれば Pass は遡及的に Fail に降格する; red の checks を抱えた PR を ready に昇格させることが、まさにこのステップが防ぎたい失敗モードだ。

## 関連項目

- 正本の契約 — PR コメントテンプレート、severity 表、anti-pattern の完全な一覧を含む — は [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md) を参照。
- verdict が PR の state machine をどう駆動するかは、[PR ライフサイクル概念](/ja/concept/pr-lifecycle/) を参照。
