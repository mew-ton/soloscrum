# /design-ui

design-ui subtaskをFigmaで制作する。

## 動作

1. 対象 Linear subtask（type: design-ui）を受け取る
2. `ui-agent` を起動し以下を実行させる
   - `soloscrum-define-ui-standards` を参照してデザイントークン・パターン確認
   - Figma MCP でデザイン制作
     - コンポーネント制作
     - デザイントークン適用
     - UIパターン整合性確認
   - State 遷移図の作成（該当する場合）
   - `soloscrum-define-dod` で DoD 確認
3. Linear subtask を In Review にステート遷移
4. ユーザーに Figma URL を提示

## 入力

- Linear subtask URL または ID
- （省略時）カレントの subtask を自動選択

## 出力

- 制作された Figma ファイル URL
- デザインサマリー
- DoD チェックリスト結果

## 使用リソース

- Subagent: `ui-agent`
- Skills: `soloscrum-design-ui-task`, `soloscrum-define-ui-standards`, `soloscrum-define-dod`
- MCP: Figma MCP（`mcp.figma.com/mcp`）
