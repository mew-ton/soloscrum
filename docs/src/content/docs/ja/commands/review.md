---
title: /review
description: DoD と AC を検証し、CodeRabbit + multi-agent review を走らせ、各 finding を決定して verdict を投稿する。Pass なら PR を ready に昇格させ、merge command を提示する。
sidebar:
  order: 4
---

`/review` は品質ゲートだ。`/develop` が開いた draft PR を読み、[DoD](/ja/policies/dod/) と Issue の各 AC を検証し、CodeRabbit と multi-agent review pipeline を走らせ、各 finding を個別に決定し、Pass / Pass with follow-ups / Fail のいずれかの verdict を投稿する。Pass なら Subtask を `done` に遷移させ、CI が green になるのを待ち、PR を ready に昇格させ、ユーザが実行すべき正確な `gh pr merge` command を surface する。merge そのものは **常に** ユーザのゲートだ。

## Usage

```bash
/review <pr-url|pr-number or figma-url>
```

PR review には PR の URL か番号を渡す。Figma ファイル (`type:design-ui` の Subtask) に対する design-fidelity review には Figma URL を渡す。

## 何が起きるか

1. **DoD の検証.** [DoD](/ja/policies/dod/) のチェックリスト項目を一つずつ確認する。PR 本文に closing keyword (`Closes #N`) が含まれていること、lint が clean であること、該当する場合はテストが揃っていること、AC が満たされていること、といった具合だ。
2. **AC の検証.** 親 Issue の AC のチェックボックスを、diff と動作するビルドに対して 1 つずつ verify する。
3. **CodeRabbit 実行.** CodeRabbit CLI を diff に対して走らせる。「No findings」が返ってきても multi-agent パスは省略しない — PR が小さい、docs だけ、といった理由で multi-agent ステップを飛ばすのは名前の付いた anti-pattern だ。
4. **multi-agent review.** 専門 agent (security、accessibility、performance など) が diff を並列で review する。confidence ≥ 80 の finding を consolidate する。
5. **finding ごとの決定.** 生き残った finding を 1 つずつ決定する: 修正するか、理由を添えて skip するか。severity は informational であって、skip の理由にはならない。
6. **Verdict.** Pass / Pass with follow-ups / Fail を、構造化された PR コメントとして投稿する。verdict コメントが正式な記録になる。
7. **verdict 後のアクション.** Pass なら、PR を承認 (`gh pr review --approve`、後述の self-approve note を参照) し、Subtask を `done` に遷移させ、CI が green になるのを待ち、PR を ready に昇格 (`gh pr ready`) させ、merge command を surface する。Fail なら、finding ごとのフィードバックを投稿し、Subtask を `in-progress` に戻し、PR は draft のままにしておく。

## 典型的な流れ

`/develop` を完了し、手元には `https://github.com/<owner>/<repo>/pull/123` のような draft PR の URL があるとする。`/review https://github.com/<owner>/<repo>/pull/123` を実行する。Review agent は DoD のチェックリストを順に確認し、diff に対して AC を tick し、CodeRabbit を走らせ、multi-agent pipeline を走らせ、flag された各 finding を決定する。各 finding は「commit X で修正済み」か「<reason> により skip」のどちらかで決着する — 「あとで考える」という経路はなく、verdict はすべての finding を解決する。

verdict が Pass なら、agent は `gh pr review --approve` を試みる (solo-dev では self-approve refusal で失敗するが、それは想定どおりだ。verdict コメントが正式な Pass の記録になる)。続いて active tracker 経由で Subtask を `done` に遷移させ、`skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr>` で CI の完了を待ち、`gh pr ready` を実行する。待機中に CI が red になれば、Pass は遡及的に Fail に降格する。最後に agent は merge command を提示する — `gh pr merge <pr-number> --squash` でも、リポジトリの好みの形でも構わない — そしてそこで止まる。**`gh pr merge` を実行するのはユーザの仕事であって、agent の仕事ではない**。verdict がどれほどクリーンに見えても、この扱いは変わらない。

verdict が Fail なら、agent は finding ごとのフィードバックを PR に投稿し、Subtask の state を `in-progress` に戻し、「もっと作業が必要」のシグナルが外部から見える状態のまま PR を draft に残す。ユーザはその後 finding に対処するために `/develop` を再実行し、次のイテレーションが整ったら `/review` を再度走らせる。

### Self-approve refusal

GitHub は PR の作者が自分の PR を承認することを許さない。soloscrum が中心に据える solo-dev のデフォルトでは、`gh pr review --approve` は `Can not approve your own pull request` で失敗する。これは Fail では **ない**。PR に投稿された verdict コメントが正式な Pass の記録であり、API 側の承認は solo-dev では構造的に生成できない重複シグナルにすぎない。実装は try-and-fall-through で書く:

```bash
gh pr review --approve "$PR_URL" \
  || echo "approve skipped (likely self-approve refusal); verdict comment is the formal Pass record"
```

verdict 後のシーケンス — tracker `→ done`、CI 待機、`gh pr ready`、merge command の提示 — はそのまま走り抜ける。

## Output

- PR 上に構造化された verdict コメント: DoD チェックリスト、AC チェックリスト、finding ごとの決定、verdict。
- Pass の場合: Subtask state が `done` に進み、PR が ready に昇格し、ユーザが実行する `gh pr merge` command が surface される。
- Fail の場合: finding ごとのフィードバックが PR に投稿され、Subtask が `in-progress` に戻り、PR は draft のままになる。

Issue そのものは `/review` によって **クローズされない** — クローズは merge 時に、PR 本文の `Closes #N` キーワードと GitHub の auto-close によって起きる。理由は [PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照。

## 関連項目

- [agent と責務](/ja/concept/agent-responsibilities/) — Pass を発行できる唯一のロールは Review だ。
- [PR ライフサイクル](/ja/concept/pr-lifecycle/) — autonomy の契約、reversible と irreversible、merge が常にユーザのゲートである理由。
- [code review プロセス](/ja/concept/code-review-process/) — finding ごとの決定ルールと verdict マッピング。
- [DoD](/ja/policies/dod/) — `/review` が照合するチェックリスト。
- ライフサイクルの前のステップ: [`/develop`](/commands/develop/)。
- 正本の契約: [`commands/review.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/review.md)。
