---
title: /review
description: DoD と AC を検証し、CodeRabbit + multi-agent review を走らせ、各 finding を判断し、verdict を投稿します。Pass なら PR を ready に昇格させて merge コマンドを提示します。
sidebar:
  order: 4
---

`/review` は soloscrum の quality gate です。`/develop` が開いた draft PR を読み、[DoD](/ja/policies/dod/) と Issue の AC を 1 つずつ検証し、CodeRabbit と multi-agent review pipeline を走らせ、見つかった finding を 1 件ずつ判断し、Pass / Pass with follow-ups / Fail のいずれかの verdict を投稿します。Pass の場合は Subtask を `done` に進め、CI green を待ち、PR を ready に昇格させ、`gh pr merge` のコマンドを提示します。merge そのものは **常に** ユーザのゲートです。

## 使い方

```bash
/review <pr-url|pr-number or figma-url>
```

- PR の review なら PR URL か番号を渡します
- `type:design-ui` Subtask の design-fidelity review なら Figma URL を渡します

## 処理の流れ

1. **DoD 検証。** [DoD](/ja/policies/dod/) の全項目を確認します。PR 本文に closing keyword（Subtask PR なら `Closes #<subtask>`、Subtask を持たない Issue なら `Closes #<issue>`）が入っていること、lint がクリーン、必要なテストが揃っていること、を確認します。AC 検証は次の項目で扱います（PR の種類によってレイヤーが変わるため）。
2. **AC 検証（適切なレイヤーで）。** Subtask PR では、スライスが配信されたこと + 親 AC への退行がないこと、を確認します。Subtask を持たない Issue の PR では、Issue の全 AC を diff と動作中のビルドに照らして検証します。親 Issue の intent 単位 AC サインオフは、すべての Subtask が close した時点で行われ、個別 Subtask PR では行われません — [DoD](/ja/policies/dod/) の *AC 検証* セクションを参照してください。
3. **CodeRabbit 実行。** CodeRabbit CLI を diff に対して走らせます。「No findings」が返ってきても multi-agent パスはスキップしません — PR が小さい / docs だけ、という理由で multi-agent を飛ばすのは anti-pattern です。
4. **multi-agent review。** 専門観点を持つ複数の agent (security / accessibility / performance など) が diff を並列で review します。confidence 80 以上の finding を集約します。
5. **finding ごとの判断。** プレフィルタを通った各 finding に対し、fix するか、理由を明記して skip するかを 1 件ずつ決めます。severity は情報用であり、skip 理由にはなりません。
6. **verdict。** Pass / Pass with follow-ups / Fail を構造化された PR コメントとして投稿します。このコメントが正式な記録です。
7. **verdict 後のアクション。** Pass の場合: PR を approve (`gh pr review --approve`、後述の self-approve refusal の注意あり) し、Subtask を `done` に進め、CI green を待ち、PR を ready に昇格 (`gh pr ready`) させ、merge コマンドを提示します。Fail の場合: finding ごとのフィードバックを投稿し、Subtask を `in-progress` に戻し、PR は draft のまま残します。

## 典型的な流れ

`/develop` を終え、`https://github.com/<owner>/<repo>/pull/123` のような draft PR の URL を持っています。`/review https://github.com/<owner>/<repo>/pull/123` を実行します。Review agent は DoD のチェックリストを順に確認し、AC を diff と突き合わせ、CodeRabbit を走らせ、multi-agent pipeline を回し、検出された finding を 1 件ずつ判断します。各 finding は「commit X で修正済み」または「skip 理由: 〜」のいずれかに収束します。「あとで考える」というオプションはありません — verdict はすべての finding を決着させた結果です。

Pass の場合、agent は `gh pr review --approve` を実行します (solo-dev では self-approve refusal で失敗する — 想定内)。続いて Subtask を `done` に進め、`skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr>` で CI を待ち、`gh pr ready` を走らせます。待っている間に CI が red になれば Pass はさかのぼって Fail に格下げです。最後に merge コマンド — `gh pr merge <pr-number> --squash` などリポジトリの方針に合わせたもの — を提示して停止します。**`gh pr merge` を実行するのはユーザの仕事であり、agent の仕事ではありません**。verdict がどれだけ綺麗でも例外はありません。

Fail の場合、agent は finding ごとのフィードバックを PR にコメントし、Subtask state を `in-progress` に戻し、PR は draft のままにします。「まだ作業が必要」というシグナルを外部から見える形で残すためです。ユーザは `/develop` を再実行して finding に対応し、`/review` をやり直します。

### self-approve refusal について

GitHub は PR の作成者本人による approve を許可していません。soloscrum が前提とする solo-dev では `gh pr review --approve` が `Can not approve your own pull request` で失敗します。これは Fail ではありません。verdict コメントこそが Pass の正式な記録で、API 側の approve は solo-dev では構造上発生し得ない重複シグナルです。try-and-fall-through のパターンで処理します。

```bash
gh pr review --approve "$PR_URL" \
  || echo "approve skipped (likely self-approve refusal); verdict comment is the formal Pass record"
```

verdict 後の一連のアクション — tracker の `→ done`、CI 待機、`gh pr ready`、merge コマンドの提示 — はそのまま続行します。

## 出力

- PR 上に構造化された verdict コメント (DoD チェックリスト、AC チェックリスト、finding ごとの判断、verdict)
- Pass の場合: Subtask state が `done`、PR が ready、`gh pr merge` のコマンドを提示
- Fail の場合: finding ごとのフィードバック、Subtask は `in-progress` に戻り、PR は draft のまま

Issue 自体は `/review` で close されません。close するのは PR の merge であり、引き金は PR 本文の `Closes #N` キーワードと GitHub の auto-close です。詳しくは [PR ライフサイクル](/ja/concept/pr-lifecycle/) を参照してください。

## 参考

- [agent と責務](/ja/concept/agent-responsibilities/) — Pass を出せる役割は Review だけ
- [PR ライフサイクル](/ja/concept/pr-lifecycle/) — autonomy の契約、reversible と irreversible、merge がユーザゲートである理由
- [code review プロセス](/ja/concept/code-review-process/) — finding ごとの判断ルールと verdict の対応
- [DoD](/ja/policies/dod/) — `/review` が照らすチェックリスト
- 前: [`/develop`](/ja/commands/develop/)
- canonical な契約: [`commands/review.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/review.md)
