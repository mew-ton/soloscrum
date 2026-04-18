# /status

現在の作業状況を確認する。

## 動作

1. Linear MCP で現在の状況を取得
   - In Progress の subtask 一覧
   - In Review の subtask 一覧
   - 直近で完了した subtask
2. GitHub で対応する PR の状況を確認
3. 状況サマリーを提示

## 入力

なし（オプションで Issue 番号を指定して絞り込み可）

## 出力

```
## 作業状況

### In Progress
- [subtask] タイトル (SP: X) — type: develop/design-ui

### In Review
- [subtask] タイトル — PR #N / Figma URL

### 直近完了
- [subtask] タイトル — Done
```

## 使用リソース

- Linear MCP（直接）
- GitHub MCP（PR 状況確認）
