# soloscrum-define-issue-size

粒度ゲートの基準値定義。

## 基準値

```yaml
max_sp: 5
max_subtasks: 5
max_estimated_days: 2
action_on_exceed: suggest_split
```

## 評価方法

以下のいずれかを超える場合、`suggest_split` アクションを実行する。

| 指標 | 閾値 | 説明 |
|---|---|---|
| SP | 5超 | SP 5 を超える見積もりは対象 |
| subtask 数 | 5超 | breakdown で 5 を超える subtask が発生する場合 |
| 推定日数 | 2日超 | 実装に 2 日を超えると見込まれる場合 |

## suggest_split アクション

1. Issue の分割案を提示する
   - 機能軸（MVPと拡張）
   - レイヤー軸（バックエンド・フロントエンド）
   - フェーズ軸（基本機能・エラーハンドリング・パフォーマンス）
2. 分割後の各 Issue が基準値内に収まることを確認する
3. ユーザーの承認を得てから分割 Issue を作成する

## 例外

- 技術的負債の解消や大規模リファクタリングはこの基準の対象外とし、ユーザーの判断に委ねる
