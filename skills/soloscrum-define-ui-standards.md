# soloscrum-define-ui-standards

デザイントークン・パターンの規約。

## デザイントークン

プロジェクトのデザイントークンは Figma の Variables または Tokens Studio で管理する。

### トークンカテゴリ

| カテゴリ | 用途 |
|---|---|
| `color` | ブランドカラー・セマンティックカラー |
| `typography` | フォントファミリー・サイズ・ウェイト・行間 |
| `spacing` | マージン・パディング・ギャップ |
| `radius` | ボーダーラジウス |
| `shadow` | ボックスシャドウ |
| `motion` | トランジション時間・イージング |

### 命名規約

```
{category}/{semantic}/{variant}

例:
color/brand/primary
color/status/error
typography/body/md
spacing/component/md
```

## コンポーネント規約

### 必須 State

全てのインタラクティブコンポーネントに以下を定義する:

| State | 必須 |
|---|---|
| Default | ✅ 必須 |
| Hover | ✅ 必須（デスクトップ） |
| Focus | ✅ 必須（アクセシビリティ） |
| Active / Pressed | 任意 |
| Disabled | ✅ 必須（disabled 状態がある場合） |
| Loading | ✅ 必須（非同期処理がある場合） |
| Error | ✅ 必須（入力バリデーションがある場合） |

### アクセシビリティ

| 基準 | 値 |
|---|---|
| テキストコントラスト比 | WCAG AA: 4.5:1 以上（通常テキスト） |
| 大きいテキストコントラスト比 | WCAG AA: 3:1 以上（18px 以上） |
| タッチターゲットサイズ | 44px × 44px 以上 |
| フォーカスインジケーター | 視認できる強調表示 |

## 新規パターン追加

既存パターンで対応できない場合:
1. ユーザーに確認してから制作する
2. Figma のコンポーネントライブラリに追加する
3. 命名・使用基準を Figma のコンポーネント説明に記載する

## 注意

このファイルは汎用の初期値である。プロジェクト固有のデザイントークン・パターンは  
Figma ファイルまたは `.claude/rules/` で上書き定義する。
