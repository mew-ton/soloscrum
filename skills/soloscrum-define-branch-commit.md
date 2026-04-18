# soloscrum-define-branch-commit

ブランチ命名・コミット規約。

## ブランチ命名

```
{type}/{issue-id}-{slug}
```

### type

| type | 用途 |
|---|---|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `refactor` | リファクタリング |
| `docs` | ドキュメント |
| `chore` | ビルド・ツール・依存関係 |
| `test` | テスト追加・修正 |

### issue-id

- GitHub Issue 番号（例: `123`）
- Linear subtask ID（例: `PRJ-42`）

### slug

- Issue タイトルをケバブケースに変換
- 最大 30 文字
- 英小文字・数字・ハイフンのみ

### 例

```
feat/123-user-password-reset
fix/PRJ-42-auth-token-expiry
```

## コミット規約

[Conventional Commits](https://www.conventionalcommits.org/) を使用する。

```
{type}({scope}): {description}

[optional body]

[optional footer]
```

### type

`feat` / `fix` / `refactor` / `docs` / `chore` / `test` / `style` / `perf`

### 例

```
feat(auth): add password reset endpoint

Implements the POST /auth/reset-password endpoint with email
verification flow.

Closes #123
```

## 注意

- リポジトリ固有のブランチ戦略は `.claude/rules/branch.md` を優先する
- main / master への直接コミットは行わない
