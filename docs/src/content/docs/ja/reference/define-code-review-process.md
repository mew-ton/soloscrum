---
title: define-code-review-process
description: spec サマリ — review pipeline (CodeRabbit + multi-agent)、finding ごとの決定ルール、draft-window override、verdict マッピング。
sidebar:
  order: 3
---

`soloscrum-define-code-review-process` は、`/review` が自動 review pipeline を実行し finding を verdict に変換するときに従う契約です。

## 何をするか

次を固定します:

- 並列で動く 2 つの review ソース: **CodeRabbit** (`coderabbit review --plain --base main`) と **multi-agent review** (`code-review:code-review` slash command 経由)。
- 事前フィルタのルール: CodeRabbit finding には事前フィルタは **なし**; multi-agent finding は 80 未満をスコアするものを drop する。
- per-item 決定: 生き残った各 finding は **Fix** または **理由を述べて Skip** として決定される。severity は情報的であり、skip 理由ではない。
- draft-window override: soloscrum から起動されたとき、multi-agent command の「draft なら skip」eligibility check は bypass される。soloscrum は意図的に draft PR で `/review` を走らせるため。
- verdict 凡例: Pass / Pass with follow-ups / Fail。
- 両ソースを統合する PR コメントテンプレート。
- verdict ごとの verdict 後アクションシーケンス。

## いつ消費されるか

`soloscrum-review-implementation` (`/review` の裏側のエンジン) が主な caller です。soloscrum ライフサイクルの外で `code-review:code-review` を branch に対して直接走らせる caller からも、ad hoc に参照されます。

## 主要な入力と出力

入力は PR (設計上 draft) と稼働中の tracker profile です。出力は:

- CodeRabbit finding + フィルタ済み agent finding + verdict を含む統合 PR コメント。
- 次アクションシーケンスを駆動する verdict (approve / state 遷移 / CI 待機 / ready に昇格、または feedback 投稿 / state を戻す / draft のまま)。

## verdict から次アクションへ

| Verdict | シーケンス |
|---|---|
| Pass | approve → subtask `→ done` → CI green を待つ → `gh pr ready` → merge command を提示 |
| Pass with follow-ups | follow-up Issue があることを確認 → Pass と同じ |
| Fail | finding ごとのフィードバックを投稿 → subtask `→ in-progress` → PR を draft のまま |

`gh pr merge` は表に **ありません** — 常にユーザゲートです。

## self-approve refusal

solo-dev で `gh pr review --approve` が「Can not approve your own pull request」で失敗するのは、failure ではなく **デフォルトで期待される結果** です。verdict コメントが正式な Pass の記録であり、残りのシーケンスはそのまま実行されます。実装パターンは try-and-fall-through です。

## 関連項目

- 人間向けのウォークスルーは [code review プロセス](/concept/code-review-process/) を参照。
- 正本の契約: [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md)。
- verdict が駆動するライフサイクルフェーズについては [PR ライフサイクル](/concept/pr-lifecycle/) を参照。
