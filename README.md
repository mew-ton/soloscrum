# soloscrum

> 一人用AI駆動開発基盤。Claude Plugin として配布する。

ドキュメントサイト: <https://mew-ton.github.io/soloscrum/>

GitHub Issues を中心に据え、必要に応じて Linear を併用しながら、個人開発のタスク管理・実装・レビューを自律的に回す。

---

## 概要

個人開発者が「アイデア → Issue → タスク分解 → 実装 → レビュー」のループを
Claude Plugin（skill / subagent / command）によって自律的に回せるようにする。

### 設計原則

- スプリント・マイルストーンの概念を持たない（個人開発に不要）
- GitHub Issue を canonical なバックログとして扱う
- 必要なら Linear をオプション層として併用（profileで切替）
- リポジトリ固有の設定は `.claude/rules/` に分離する
- Skill はフラット構造・指示的命名（`soloscrum-` プレフィクス）

---

## Tracker Profile

soloscrum はリポジトリごとに2種類の **tracker profile** を切り替えられる:

| Profile | 用途 |
|---|---|
| `github-only` | デフォルト。GitHub Issues のみ使うリポジトリ向け |
| `linear+github` | Linear MCP と GitHub→Linear ネイティブ同期が有効なリポジトリ向け |

profile によって変わるのは「subtask / SP / state / dependencies の保管場所と API」だけで、概念モデル・ライフサイクル・各エージェントの責務は共通。

### Profile の解決順

1. `.claude/rules/tracker.md` の frontmatter `profile:` （リポジトリ単位の上書き）
2. plugin user config `tracker_profile` （ユーザーデフォルト）
3. built-in default `github-only`

詳細は `skills/soloscrum-define-tracker-profile/SKILL.md` を参照。

---

## 開発フロー

```
アイデア
  │
  ▼
/soloscrum:refine             Issue構造化・粒度チェック・優先度・SP
  │
  ▼
/soloscrum:validate           機能設計の妥当性・スコープ・依存関係の検証
  │
  ▼
/soloscrum:breakdown          subtask分解・タイプ付与（develop / design-ui）
  │
  ├─── type: develop ───────────────────────┐
  │                                         ▼
  │                                      /soloscrum:develop
  │                                      コード実装・PR生成・State遷移
  │
  └─── type: design-ui ─────────────────────┐
                                            ▼
                                         /soloscrum:design-ui
                                         Figma制作・トークン・パターン構築・State遷移
  │
  ▼
/soloscrum:review             品質・DoD照合・SubtaskをDoneに遷移・PRをreadyに promote
                              (Issueクローズはマージ時のGH `Closes #N` 自動クローズで発火)
```

---

## Commands

| コマンド | 説明 |
|---|---|
| `/soloscrum:refine` | アイデアをIssueに構造化する |
| `/soloscrum:validate` | 機能設計の妥当性を検証する |
| `/soloscrum:breakdown` | IssueをSubtaskに分解しタイプを付与する |
| `/soloscrum:develop` | develop Subtaskを実装する |
| `/soloscrum:design-ui` | design-ui SubtaskをFigmaで制作する |
| `/soloscrum:review` | 実装・デザインをレビューしSubtaskをDoneに遷移する（Issueクローズはマージ時に発火） |
| `/soloscrum:status` | 現在の作業状況を確認する |
| `/soloscrum:next` | 次にやるべきことを提示する |
| `/soloscrum:cleanup` | マージ済みブランチの worktree を回収する |

### コマンド名前空間

`soloscrum:` の部分は `.claude-plugin/plugin.json` の `name` フィールドに由来する。Claude Code はプラグインが配布するコマンドを `<plugin-name>:<command-name>` として登録するため、他のプラグインが同名のコマンドを持っていても衝突しない。

`/refine` のような素の形も、そのコマンド名を要求する他のプラグインが入っていなければ解決する。ただし解決するかどうかはインストール済みプラグインの構成に依存するため、**ドキュメント・spec・ユーザーへの提示はすべて名前空間付きの `/soloscrum:<name>` を正規表記とする**。

`.claude/commands/` に置かれたリポジトリローカルのコマンド（このリポジトリの `/audit` など）はプラグイン配布物ではないため名前空間が付かない。素の形が正しい表記になる。

---

## 前提条件

- GitHub CLI (`gh`) がインストール・認証済み
- `github-only` profile では GitHub Projects v2 と Sub-issue が利用可能なリポジトリであること
- `linear+github` profile を使う場合は Linear MCP 接続済み・Linear native GitHub Integration が有効
- Figma 関連は Figma MCP 接続済み（`design-ui` タスクを使う場合のみ）

---

## リポジトリ固有設定

各プロジェクトリポジトリに以下を配置する（soloscrum 本体には含めない）。

```
.claude/rules/
  tracker.md      profile上書き（任意）。frontmatter `profile: github-only|linear+github`
  stack.md        技術スタック・ディレクトリ構成・命名規約
  branch.md       このリポジトリのブランチ戦略。worktree 置き場の上書きも任意で
                  frontmatter `worktree_root: <repo相対パス>`
  dod-extra.md    リポジトリ固有のDoD追加条件
```

---

## ディレクトリ構成

```
soloscrum/
  README.md
  .claude-plugin/
    plugin.json     userConfig.tracker_profile を含む
    marketplace.json
  commands/         コマンド定義
  agents/           エージェント定義
  skills/           スキル定義（define-* / tracker-{profile}-* / その他）
```

導入先リポジトリでは、これに加えて `/soloscrum:develop` が作業用の worktree を作る。

```
<リポジトリ>/
  .soloscrum/worktrees/     worktree 置き場（gitignore 対象）
    feat/123-some-slug/     ブランチ 1 本につき 1 worktree
```

メインのチェックアウトはデフォルトブランチのまま保たれ、feature ブランチに切り替わることはない。マージ済みの worktree は `/soloscrum:cleanup` が回収する。置き場は `.claude/rules/branch.md` の `worktree_root` で変更できる。詳細は `skills/soloscrum-define-worktree/SKILL.md` を参照。
