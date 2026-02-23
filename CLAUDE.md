# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MailAddress は Perl の `Mail::Address` モジュールを Ruby に移植したメールアドレスパーサー gem。RFC非準拠のアドレス（docomo/au などの日本のキャリアメールで使われる `..` や末尾 `.`）もパース可能。ランタイム依存なし（Pure Ruby）。

## Commands

```bash
# テスト実行（デフォルトの rake タスク）
bundle exec rake spec

# 特定ファイルのテスト
bundle exec rspec spec/mail_address_spec.rb

# 特定行のテスト
bundle exec rspec spec/mail_address_spec.rb:10
```

リンターは未設定。

## Architecture

### コア構造

- **`lib/mail_address.rb`** — エントリポイント。`MailAddress.parse`, `MailAddress.parse_first`, `MailAddress.parse_simple` を提供
- **`lib/mail_address/address.rb`** — `MailAddress::Address` クラス。パース結果を保持（`phrase`, `address`, `original`）し、`name`, `host`, `user`, `format` メソッドを提供
- **`lib/mail_address/mail_address.rb`** — メインのパースロジック。トークン化と複雑なアドレスフォーマットの処理
- **`lib/mail_address/simple_parser.rb`** — Google Closure Library ベースのシンプルパーサー（スペース/カンマ区切りのアドレス向け）

### パース戦略

2つのパーサーを使い分ける:
- **メインパーサー** (`parse`) — RFC準拠・非準拠の複雑なフォーマットを処理。括弧コメント、クォート、MIME エンコードなどに対応
- **シンプルパーサー** (`parse_simple` / `g_parse`) — 空白・カンマ区切りの単純なリスト向け

### コーディング規約

- プライベートメソッドは `_` プレフィックス（例: `_tokenize`, `_complete`）
- 定数は `UPPER_CASE`
- テストは RSpec 3 の `expect` 構文を使用
