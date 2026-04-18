# /next

次にやるべきことを提示する。

## 動作

1. Linear MCP でバックログを取得
2. 優先度・SP・依存関係を考慮して次のアクションを判定
3. 推奨アクションをユーザーに提示

## 判定ロジック

1. In Progress の subtask がある → `そのまま続けてください`
2. In Review の subtask がある → `/review` を提案
3. Backlog に未着手 subtask がある → 最優先の subtask で `/develop` または `/design-ui` を提案
4. 全 subtask 完了・未分解 Issue がある → `/breakdown` を提案
5. バックログが空 → 新しいアイデアを `/refine` することを提案

## 入力

なし

## 出力

```
## 次のアクション

推奨: /develop [subtask-id]
理由: 優先度 High、SP: 2、依存なし

または

推奨: /review PR #N
理由: In Review の subtask があります
```

## 使用リソース

- Linear MCP（直接）
