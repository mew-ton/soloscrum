---
title: code review プロセス
description: "`/soloscrum:review` が CodeRabbit と multi-agent review pipeline をどう走らせるか、severity を情報扱いに留める理由、各 finding が verdict にどう収束するかを説明します。"
sidebar:
  order: 4
---

`/soloscrum:review` は 3 つの source を使い、その出力を 1 つの PR コメントにまとめます。CodeRabbit と multi-agent review は並列に走り、蓄積したレビュー観点はそのあとに選択・適用されます。どの source から出てきた finding も、最終的に **修正する** か **理由を明記して skip する** のどちらかに落ちます。「severity が低いので無視する」という第三の道はありません。

## 3 つの review source

**CodeRabbit** は `coderabbit review --plain --base main` で実行します。finding には `critical` / `major` / `minor` / `nitpick` のタグが付きますが、これは issue の種類を表すラベルであって、skip 判断のための severity ではありません。スコープ内で内容も正しい `nitpick` は、修正する価値があります。

**multi-agent review** は `code-review:code-review` slash command で実行します。このコマンドは複数の Sonnet agent を並列起動し、security / architecture / bug scan / history / in-file rules / coverage gaps といった観点ごとに review させます。別途 Haiku agent が各 finding に 0-100 のスコアを付けます。スコアは新規 agent が制約を捏造したりルールを誤って引用したりするノイズ傾向を踏まえて調整されています。

**レビュー観点 (review perspectives)** は、利用者自身が蓄積した判断です。マシンローカルの `~/.claude/review-perspectives/` に置かれ、[`/soloscrum:collect-perspective`](/ja/commands/collect-perspective/) で収集します。前の 2 つが一般的なレビューであるのに対し、これは**その利用者が具体的に学んだこと**であり、二度と学び直したくないものです。レビューは各観点の `description` だけを読んで適用対象を決め、選ばれたものの本文だけを読みます。観点が 1 件も無い状態は正常な初期状態で、その場合このステップは黙ってスキップされ、不足として報告されることはありません。

3 つの source の finding は集約され、末尾に 1 行の verdict を持つ単一の PR コメントとして投稿されます。

## しきい値を使い分ける理由

source ごとに失敗の出方が違うので、フィルタも別にしてあります。

- **CodeRabbit の finding はツール側ですでにフィルタ済み。** severity は情報用であって、最下位の tier であっても文書化された pattern に対応しています。severity で再フィルタすると、正当なシグナルを取りこぼします。
- **multi-agent の reviewer は PR ごとに新規起動。** 制約を hallucinate したり、意図のある変更を flag したりしがちです。confidence 80 のプレフィルタは、その種のノイズを抑えるために設定されています。

- **レビュー観点には別種のガードが要る。** 観点そのものは信頼できます（利用者が書き、収集時に確認済み）。しかしそこから出た **finding** は別です。finding を作ったのは diff を読んだモデルであり、confidence フィルタが守ろうとしているのと同じ経路です。「ルールが妥当である」ことと「この適用事例が実在する」ことは別の主張です。

  そこで観点由来の finding には confidence スコアを付けない代わりに、**根拠 (grounding) を要求**します。各 finding は、この PR の diff 上の位置と、観点本文のどのチェックを適用したのかを示さなければなりません。両方を示せない finding は「裏付けなし」として破棄します。これは幻覚由来の適用事例を直接狙い撃ちします。スコアで切ると、スコア側が自信を持てなかっただけの正しい finding まで落ちてしまいます。

confidence のプレフィルタは multi-agent 側にだけ適用します。フィルタを通った finding は、source を問わず同じ per-item 判断にかけます。

観点由来の finding には、どの観点が出したかを記録し、さらにコーパスに何件あって何件が選ばれたかを報告します。この 1 行が無いと、トリガが狭すぎて二度と発火しない観点と、今回はたまたま関係なかった観点が区別できません。コーパスは黙って腐り、それを知らせるものが何もない状態になります。

同じ欠陥が複数の source から届くこともあります（観点は、組み込みのレンズが既にカバーしている判断を意図的に含むため）。その場合は最もよく説明できた source の節で **1 回だけ**報告し、他にどの source が挙げたかを併記します。

両者を混ぜる挙動 — agent 用の confidence フィルタを CodeRabbit に適用したり、confidence 80 未満の agent finding を「もっともらしいから」と通したり — は anti-pattern として明示的に禁止しています。

## per-item の判断

judgement ステップに到達した finding は、reviewer が 1 件ごとに **fix** か **理由付きの skip** かを決めます。

次の 3 つがすべて成り立つときに **fix** を選びます。

1. **スコープ内** であること。PR の diff で導入または直接変更したコードや挙動に対する指摘である
2. 指摘が **正しい** こと。実在する問題を指摘しており、提案された変更がその問題に対応している
3. 修正範囲が **限定的** であること。PR がすでに触れているファイル (またはそのすぐ隣) で完結し、別件のリファクタに波及しない

この 3 つを満たし、かつ修正コストが小さければ、`nitpick` でも修正します。

次のいずれかが成り立つ場合は **理由を明記して skip** します。

- スコープ外 — follow-up Issue を立て、その Issue 番号を skip コメントに書く
- 指摘が誤り、または diff の読み違いに基づく — 具体的な読み違いを明示する
- プロジェクトの明示的な convention と衝突する — どの convention かを明示する

skip 理由として **無効** なもの:

- 「nitpick だから」「minor だから」 — severity は skip 理由になりません
- 「solo dev だから skip」 を具体的な根拠なしに書く — なぜ solo dev だとこの finding が当てはまらないのかを説明します
- 「あとで直す」 を tracking link なしで書く — Issue にして番号を残します

## draft 窓のオーバーライド

`code-review:code-review` command は eligibility check を持っており、draft 状態の PR を skip します。soloscrum はこの check を **意図的にバイパスします**。`/soloscrum:review` が走るとき PR は draft 状態にあり、それは [draft 窓](/ja/concept/pr-lifecycle/) がまさに local の quality gate を走らせるための時間枠だからです。上流の skip をそのまま尊重すると、review pipeline の半分が動かなくなります。

`code-review:code-review` が明示的な override 引数を提供しているなら、それを使います。それまでは、soloscrum の `/soloscrum:review` は draft PR を eligible として扱います。

## verdict

verdict は 3 種類です。どれになるかは、表面化した finding をどう処理したかだけで決まります。

- **Pass** — 表面化したすべての finding を fix と判断し、その修正がこの PR に入っている (もしくは finding が 1 件もなかった)
- **Pass with follow-ups** — すべての finding を判断したが、1 件以上が *スコープ外として skip* され、別の follow-up Issue に切り出されている。PR は merge 可能で、follow-up Issue が存在している
- **Fail** — 修正されておらず正当な「スコープ外」でもない、correctness / security / DoD 違反の finding が 1 件以上残っている

どの source からも判断対象の finding が出なかった場合 (CodeRabbit が「No findings ✔」、multi-agent でも confidence 80 以上の finding がなく、観点由来の finding も無い) は、定型の「No issues found」コメントを投稿します。

## verdict が確定した後

verdict 後のアクションの詳細は [PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照してください。要約は次のとおりです。

| Verdict | 次の手順 |
|---|---|
| Pass | approve → subtask `→ done` → CI green を待つ → `gh pr ready` → merge コマンドを提示 |
| Pass with follow-ups | follow-up Issue の存在を確認 → 以降は Pass と同じ |
| Fail | finding ごとのフィードバックを投稿 → subtask `→ in-progress` → PR は draft のまま |

押さえておきたい点が 2 つあります。

- solo-dev では `gh pr review --approve` が「Can not approve your own pull request」で失敗します。これは verdict を変えるものではありません。verdict コメントが Pass の正式な記録なので、後続の手順はそのまま走ります。
- `→ done` と `gh pr ready` の間にある CI green 待ちは Pass の契約に含まれます。途中で red になれば Pass はさかのぼって Fail に格下げです。red のまま PR を ready に昇格させる事故を、この step で防いでいます。

## 参考

- canonical な契約 — PR コメントテンプレート、severity 表、anti-pattern の全リスト: [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md)
- verdict が PR の state machine をどう動かすか: [PR ライフサイクル](/ja/concept/pr-lifecycle/)
