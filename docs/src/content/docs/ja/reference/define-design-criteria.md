---
title: define-design-criteria
description: spec サマリ — scope の明確さ、依存関係の特定、技術的フィージビリティでの機能設計検証。
sidebar:
  order: 4
---

`soloscrum-define-design-criteria` は、`/validate` (および `/breakdown` の planning ステージ) が、Issue が subtask に分解できるほど準備できているか、それとも PO がもう一度パスする必要があるかを判断するために使うチェックリストです。

## 何をするか

3 つの評価視点を定義し、それを Pass / Conditional Pass / Fail の verdict に変換します:

1. **scope の明確さ** — Goal が 1–2 文で述べられているか、AC が検証可能か (「実装する…」ではなく「user can …」)、Out of Scope が明示的か、scope が単一機能に収まるか?
2. **依存関係** — 他の Issue への依存関係が記述されているか、外部 API / サービスへの依存関係が確認されているか、データ変更 (schema migration など) が考慮されているか?
3. **技術的フィージビリティ** — 設計が既存アーキテクチャと整合するか、tech stack が対応可能か (`.claude/rules/stack.md` と相互参照)、性能やセキュリティ上の懸念があるか?

## いつ消費されるか

`soloscrum-validate-feature` (`/validate` の裏側のエンジン) が直接これを読みます。Design agent も `/breakdown` で breakdown を提案するときに参照します。

## 主要な入力と出力

入力は Issue 本文 — Goal、AC、Out of Scope、加えて PO が Notes に書いたもの — です。出力は構造化された評価です:

- 視点ごと: OK / 修正必要 + ノート。
- 全体 verdict: **Pass** (すべて OK)、**Conditional Pass** (小さな修正必要)、または **Fail** (scope が不明、フィージブルでない、依存関係問題)。

Conditional Pass は通常 `/refine` に小さなタッチアップのために戻り、Fail は再設計のために戻ります。

## 関連項目

- 正本の契約: [`skills/soloscrum-define-design-criteria/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-design-criteria/SKILL.md)。
- scope check で使われる AC 記述ルールは [`define-issue-format`](/reference/define-issue-format/) を参照。
