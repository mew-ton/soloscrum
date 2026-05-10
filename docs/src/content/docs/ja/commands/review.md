---
title: /review
description: DoD と AC を verify し、CodeRabbit + multi-agent review を走らせ、各 finding を決定し、verdict を投稿し、Pass なら PR を ready に昇格させ merge command を提示する。
sidebar:
  order: 4
---

`/review` は品質ゲートです。`/develop` が開いた draft PR を読み、[DoD](/policies/dod/) と各 Issue AC を verify し、CodeRabbit と multi-agent review pipeline を走らせ、各 finding を個別に決定し、Pass / Pass with follow-ups / Fail verdict を投稿します。Pass なら Subtask を `done` に遷移させ、CI green を待ち、PR を ready に昇格させ、ユーザが実行する正確な `gh pr merge` command を surface します。merge そのものは **常に** ユーザのゲートです。

## Usage

```bash
/review <pr-url|pr-number or figma-url>
```

PR review には PR URL または番号を渡します。Figma ファイル (`type:design-ui` Subtask) の design-fidelity review には Figma URL を渡します。

## What happens

1. **DoD verification.** [DoD](/policies/dod/) の各チェックリスト項目が check されます。PR 本文に closing keyword (`Closes #N`) が含まれること、lint が clean、該当する場合のテスト、AC が満たされていること。
2. **AC verification.** 親 Issue の AC の各 checkbox が diff および動作する build に対して verify されます。
3. **CodeRabbit run.** CodeRabbit CLI が diff に対して走ります。"No findings" 結果でも multi-agent パスは依然として要求されます — PR が小さい / docs only だからと multi-agent ステップをスキップすることは named anti-pattern です。
4. **Multi-agent review.** 専門 agent (security, accessibility, performance など) が並列で diff を review します。confidence ≥ 80 の finding が consolidate されます。
5. **Per-finding decision.** 生き残った各 finding は個別に決定されます: 修正するか、reason を述べてスキップするか。severity は informational であって skip reason ではありません。
6. **Verdict.** Pass / Pass with follow-ups / Fail が構造化された PR コメントとして投稿されます。verdict コメントが正式な記録です。
7. **Post-verdict actions.** Pass の場合: PR を承認 (`gh pr review --approve`、下記の self-approve note を参照)、Subtask を `done` に遷移、CI が green になるのを待つ、PR を ready に昇格 (`gh pr ready`)、merge command を surface。Fail の場合: finding ごとのフィードバックを投稿、Subtask を `in-progress` に戻す、PR を draft のままにする。

## Typical flow

`/develop` を完了し、`https://github.com/<owner>/<repo>/pull/123` のような draft PR URL があるとします。`/review https://github.com/<owner>/<repo>/pull/123` を実行します。Review agent は DoD チェックリストを歩き、diff に対して AC を tick し、CodeRabbit を走らせ、multi-agent pipeline を走らせ、flag された各 finding を決定します。それぞれが「commit X で修正済み」または「<reason> によりスキップ」のいずれかで終わります — 「あとで考える」パスはありません; verdict は各 finding を解決します。

verdict が Pass の場合、agent は `gh pr review --approve` を実行 (solo-dev では self-approve refusal で失敗します — それは想定通り; verdict コメントが正式な Pass 記録です)。active tracker 経由で Subtask を `done` に遷移させ、`skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr>` で CI を待ち、`gh pr ready` を実行します。待機中に CI が red になれば、Pass は遡及的に Fail に降格されます。最後に agent は merge command — `gh pr merge <pr-number> --squash` または repo が好む形 — を surface して停止します。**`gh pr merge` を実行するのはユーザの仕事であって agent の仕事ではありません**、verdict がどれほどクリーンだったかに関わらず。

verdict が Fail の場合、agent は finding ごとのフィードバックを PR に投稿し、Subtask の state を `in-progress` に戻し、「もっと作業が必要」シグナルが外部から見えるように PR を draft のままにします。ユーザはその後 finding に対処するために `/develop` を再実行し、次のイテレーションが ready になったら `/review` を再実行します。

### Self-approve refusal

GitHub は PR の作者が自分の PR を承認することを許可しません。soloscrum が中心に据える solo-dev のデフォルトでは、`gh pr review --approve` は `Can not approve your own pull request` で失敗します。これは Fail では **ありません**。PR に投稿された verdict コメントが正式な Pass 記録であり、API 側の承認は solo-dev が構造的に生成できない重複シグナルです。実装は try-and-fall-through です:

```bash
gh pr review --approve "$PR_URL" \
  || echo "approve skipped (likely self-approve refusal); verdict comment is the formal Pass record"
```

verdict 後のシーケンス — tracker `→ done`、CI 待機、`gh pr ready`、merge command の提示 — はそのまま実行されます。

## Output

- PR 上の構造化された verdict コメント: DoD チェックリスト、AC チェックリスト、finding ごとの決定、verdict。
- Pass の場合: Subtask state が `done` に進み、PR が ready に昇格し、ユーザが実行する `gh pr merge` command が surface される。
- Fail の場合: finding ごとのフィードバックが PR に投稿され、Subtask が `in-progress` に戻され、PR は draft のまま残る。

Issue そのものは `/review` によって **クローズされません** — クローズは merge 時に PR 本文の `Closes #N` キーワードと GitHub の auto-close 経由で発火します。なぜかは [PR lifecycle](/concept/pr-lifecycle/) を参照。

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Review が Pass を発行できる唯一のロール。
- [PR lifecycle](/concept/pr-lifecycle/) — autonomy の契約、reversible vs irreversible、なぜ merge は常にユーザのゲートか。
- [Code review process](/concept/code-review-process/) — finding ごとの決定ルールと verdict マッピング。
- [DoD](/policies/dod/) — `/review` が照合するチェックリスト。
- ライフサイクルの前: [`/develop`](/commands/develop/)。
- 正本の契約: [`commands/review.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/review.md)。
