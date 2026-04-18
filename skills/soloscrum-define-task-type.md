# soloscrum-define-task-type

subtaskタイプ（develop / design-ui）と付与基準。

## タイプ定義

| タイプ | 定義 | 担当 subagent |
|---|---|---|
| `develop` | コード変更を伴う全ての作業 | `dev-agent` |
| `design-ui` | Figma・デザイントークン・UIパターンの作業 | `ui-agent` |

## 付与基準

### `develop` を付与する場合

- バックエンド実装（API、DB、バッチ等）
- フロントエンド実装（ロジック、状態管理、APIコール等）
- コンポーネントの動作実装（デザインが確定した後の実装）
- テスト実装
- インフラ設定

### `design-ui` を付与する場合

- 新規 UI コンポーネントの Figma 制作
- デザイントークンの定義・更新
- UIパターンの策定
- 画面遷移・State フローのデザイン定義

## 同一 subtask に両タイプは付与しない

- UI を伴う機能は `design-ui` → `develop` の順で別 subtask に分ける
- `design-ui` subtask の完了後に `develop` subtask を着手する

## ラベル

Linear では以下のラベルを使用する:
- `type:develop`
- `type:design-ui`
