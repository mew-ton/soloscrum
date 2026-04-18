# soloscrum

> 一人用AI駆動開発基盤。Claude Plugin として配布する。

Linear + GitHub を外部連携とし、個人開発のタスク管理・実装・レビューを自律的に回す。

---

## 概要

個人開発者が「アイデア → Issue → タスク分解 → 実装 → レビュー」のループを  
Claude Plugin（skill / subagent / command）によって自律的に回せるようにする。

### 設計原則

- スプリント・マイルストーンの概念を持たない（個人開発に不要）
- Linear バックログ = タスクキュー として扱う
- GitHub Issue を主とし、Linear Task はネイティブ同期に委ねる
- リポジトリ固有の設定は `.claude/rules/` に分離する
- Skill はフラット構造・指示的命名（`soloscrum-` プレフィクス）

---

## 開発フロー

```
アイデア
  │
  ▼
/refine             Issue構造化・粒度チェック・優先度・SP
  │
  ▼
/validate           機能設計の妥当性・スコープ・依存関係の検証
  │
  ▼
/breakdown          subtask分解・タイプ付与（develop / design-ui）
  │
  ├─── type: develop ───────────────────────┐
  │                                         ▼
  │                                      /develop
  │                                      コード実装・PR生成・State遷移
  │
  └─── type: design-ui ─────────────────────┐
                                            ▼
                                         /design-ui
                                         Figma制作・トークン・パターン構築・State遷移
  │
  ▼
/review             品質・DoD照合・Issueクローズ
```

---

## Commands

| コマンド | 説明 |
|---|---|
| `/refine` | アイデアをIssueに構造化する |
| `/validate` | 機能設計の妥当性を検証する |
| `/breakdown` | IssueをLinear subtaskに分解しタイプを付与する |
| `/develop` | develop subtaskを実装する |
| `/design-ui` | design-ui subtaskをFigmaで制作する |
| `/review` | 実装・デザインをレビューしIssueをクローズする |
| `/status` | 現在の作業状況を確認する |
| `/next` | 次にやるべきことを提示する |

---

## 前提条件

- Linear MCP 接続済み（`mcp.linear.app/mcp`）
- Figma MCP 接続済み（`mcp.figma.com/mcp`）
- GitHub Integration（Linear ネイティブ）有効

---

## リポジトリ固有設定

各プロジェクトリポジトリに以下を配置する（soloscrum 本体には含めない）。

```
.claude/rules/
  stack.md        技術スタック・ディレクトリ構成・命名規約
  branch.md       このリポジトリのブランチ戦略
  dod-extra.md    リポジトリ固有のDoD追加条件
```

---

## ディレクトリ構成

```
soloscrum/
  README.md
  commands/        コマンド定義
  agents/          エージェント定義
  skills/          スキル定義
```
