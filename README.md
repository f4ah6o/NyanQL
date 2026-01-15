# NyanQL

NyanQL（にゃんくる）は、SQL を実行して JSON を返す API サービスです。

内部に保存された SQL ファイルや JavaScript ファイルを API 設定により選択し、実行結果を JSON 形式で返します。さらに、Push 機能を利用すると、ある API の実行結果を WebSocket 経由で別のクライアントに自動配信できます。

NyanQL には以下の機能があります：

- **SQL 実行**：動的パラメータ置換、条件分岐ブロック対応
- **JavaScript スクリプト実行**（`script`）：自由に JSON を生成
- **リクエスト検証**（`check`）：入力パラメータの事前検証
- **WebSocket Push**：別 API へのリアルタイム配信

関連プロジェクト：

- **Nyan8**（にゃんぱち）：JavaScript 実行で JSON 生成
- **NyanPUI**（にゃんぷい）：HTML 生成

---

## 目次

1. [対応データベース](#対応データベース)
2. [インストールと実行](#インストールと実行)
3. [Vite + HTMX デモ](#vite--htmx-デモ)
4. [設定ファイル](#設定ファイル)
    - [config.json](#configjson)
    - [api.json](#apijson)
5. [SQL テンプレート構文](#sql-テンプレート構文)
    - [パラメータ置換](#パラメータ置換)
    - [条件分岐ブロック](#条件分岐ブロック)
6. [JavaScript Script / Check](#javascript-script--check)
7. [ファイル操作ユーティリティ](#ファイル操作ユーティリティ)
8. [サーバ情報取得エンドポイント](#サーバ情報取得エンドポイント)
9. [レスポンス形式](#レスポンス形式)
10. [アクセス方法](#アクセス方法)
11. [JSON-RPC サポート](#json-rpc-サポート)
12. [予約語](#予約語)

---

## 対応データベース

- MySQL
- PostgreSQL
- SQLite
- DuckDB

---

## インストールと実行

1. GitHub Releases からホスト OS に合わせた ZIP をダウンロード
2. `config.json` と `api.json` を編集
3. ターミナル または ダブルクリックで実行

> リリース: https://github.com/NyanQL/NyanQL/releases

---

## Vite + HTMX デモ

`demo/` に簡単に試せるフロントエンドがあります。送信した文字列が HTML で返り、画面に表示されます。

```sh
make demo
```

終了後に生成物を削除する場合:

```sh
make demo-clean
```

`make demo-clean` は `stamps.db` も削除します（デモの再生成が必要になります）。

手動で実行する場合:

1. `sqlite3 ./stamps.db < ./sql/sqlite/demo_init.sql`
2. `go build -o NyanQL .`
3. `./NyanQL`
4. `cd demo && pnpm install && pnpm dev`
5. ブラウザで `http://localhost:5173`

- `/demo_message` を Vite がプロキシし、HTMX の `HX-Request` で HTML レスポンスを受け取ります。
- BasicAuth はデフォルト `neko:nyan`。環境変数で変更した場合は `demo/index.html` の `hx-headers` も更新してください。
- `api.json` が SQL テンプレートと HTML テンプレートを紐付ける点が NyanQL の特徴です。
- デモ画面ではレンダリング結果と HTML レスポンスの生文字列を切り替えて確認できます。

---

## 設定ファイル {#設定ファイル}

### config.json {#configjson}

NyanQL サーバの全体設定を記述します。

```json
{
  "name": "API サーバ名",
  "profile": "サーバの概要説明",
  "version": "v1.0.0",
  "Port": 8080,
  "CertPath": "./cert.pem",
  "KeyPath": "./key.pem",
  "DBType": "postgres",
  "DBUser": "user",
  "DBPassword": "pass",
  "DBName": "dbname",
  "DBHost": "localhost",
  "DBPort": "5432",
  "MaxOpenConnections": 10,
  "MaxIdleConnections": 5,
  "ConnMaxLifetimeSeconds": 300,
  "BasicAuth": {
    "Username": "admin",
    "Password": "secret"
  },
  "log": {
    "Filename": "./logs/nyanql.log",
    "MaxSize": 5,
    "MaxBackups": 3,
    "MaxAge": 7,
    "Compress": true,
    "EnableLogging": true
  },
  "javascript_include": [
    "./javascript/lib/nyanRequestCheck.js",
    "./javascript/common.js"
  ]
}
```

- **Port**: HTTP/HTTPS ポート
- **CertPath/KeyPath**: SSL 証明書（HTTPS 有効化）
- **DBType**: `mysql` | `postgres` | `sqlite` | `duckdb`
- **接続プール**: `MaxOpenConnections` / `MaxIdleConnections` / `ConnMaxLifetimeSeconds`
- **BasicAuth**: ベーシック認証の設定（環境変数で上書き可能）
- **javascript_include**: `check` や `script` 実行前に読み込む JS

BasicAuth の環境変数（設定された値が `config.json` より優先されます）:

```sh
export NYANQL_BASIC_AUTH_USER="admin"
export NYANQL_BASIC_AUTH_PASSWORD="secret"
```

<details>
<summary>ログ設定項目の説明</summary>

* **Filename** – 出力先ファイルパス
* **MaxSize** – 1 ファイルの上限サイズ（MB）
* **MaxBackups** – 保持世代数
* **MaxAge** – 保持日数
* **Compress** – 過去ファイルを gzip 圧縮
* **EnableLogging** – false で標準出力のみ

</details>

---

### api.json {#apijson}

各 API エンドポイントごとに実行する SQL/スクリプトを定義します。

```json
{
  "list": {
    "sql": ["./sql/sqlite/list.sql"],
    "template": "./templates/list.html",
    "description": "当月の一覧を表示します。"
  },
  "check": {
    "check": "./javascript/check.js",
    "sql": ["./sql/sqlite/check_day.sql"],
    "template": "./templates/default.html",
    "description": "パラメータ検証と検索を同時に行います。"
  },
  "stamp": {
    "sql": ["./sql/sqlite/insert_stamp.sql"],
    "template": "./templates/default.html",
    "description": "本日のスタンプを記録します。",
    "push": "list"
  }
}
```

- `template`: Go の `html/template` で描画する HTML テンプレートのパス。`HX-Request: true`（htmx）または `?format=html` の場合に HTML を返します。同じテンプレートを複数 API で共有できます。

---

## SQL テンプレート構文 {#sql-テンプレート構文}

### パラメータ置換 {#パラメータ置換}

```sql
SELECT count(id) AS this_days_count
FROM stamps
WHERE date = /*date*/'2025-02-15';
```

リクエスト `?date=2024-02-15` で動的に置換されます。

### 条件分岐ブロック {#条件分岐ブロック}

```sql
SELECT id, date FROM stamps
/*BEGIN*/
 WHERE
   /*IF id != null*/ id = /*id*/1 /*END*/
   /*IF date != null*/ AND date = /*date*/'2024-06-25' /*END*/
/*END*/;
```

条件に応じて WHERE 部分が自動展開されます。

---

## JavaScript Script / Check {#javascript-script--check}

- **check**: 入力検証用の JS。失敗時に `{ success:false, status:400, error:{ message: ... }}` を返す。
- **script**: 自由に JSON を生成。`nyanRunSQL` や `nyanAllParams` が利用可能。
- **nyan_mode=checkOnly**: HTTP リクエストまたは JSON-RPC で `nyan_mode=checkOnly` パラメータを指定すると、`check` スクリプトのみを実行し、その結果を返します。`script` や SQL の実行は行われません。

---

## ファイル操作ユーティリティ {#ファイル操作ユーティリティ}

### `nyanBase64Encode(data: string): string`
文字列を Base64 エンコードして返します。

### `nyanBase64Decode(b64: string): string`
Base64 をデコードして元の文字列を返します。

### `nyanSaveFile(b64: string, destPath: string)`
エンコード済み Base64 をデコードし、`destPath` にファイル保存します。

```js
const raw = "こんにちは！ にゃんくる";
const b64 = nyanBase64Encode(raw);
nyanSaveFile(b64, "./storage/hello.txt");
```

---

## サーバ情報取得エンドポイント {#サーバ情報取得エンドポイント}

### `GET /nyan`
サーバの基本情報と利用可能な API 一覧を取得します。

**レスポンス例**
```json
{
  "name": "API サーバ名",
  "profile": "サーバの概要説明",
  "version": "v1.0.0",
  "apis": {
    "list": { "description": "当月の一覧を表示します。" },
    "stamp": { "description": "本日のスタンプを記録します。" }
  }
}
```

### `GET /nyan/{API名}`
指定した API の詳細情報（説明、受け入れ可能パラメータ、出力カラム）を取得します。

**レスポンス例**
```json
{
  "api": "list",
  "description": "当月の一覧を表示します。",
  "nyanAcceptedParams": { "date": "2024-06-25" },
  "nyanOutputColumns": ["id", "date"]
}
```

---

## レスポンス形式 {#レスポンス形式}

### 成功時

```json
{
  "success": true,
  "status": 200,
  "result": [...]
}
```

### エラー時

```json
{
  "success": false,
  "status": 500,
  "error": { "message": "..." }
}
```

### HTML (htmx)

`template` が設定されていて、`HX-Request: true`（htmx）または `?format=html` の場合は HTML を返します。
テンプレートには以下が渡されます。

- `API` (string)
- `Success` (bool)
- `Status` (int)
- `Result` (SQL/Script の JSON をパースした値)
- `ResultJSON` (string, pretty JSON)
- `Params` (リクエストパラメータ)

**テンプレート例**
```html
<div class="nyan-default" data-api="{{ .API }}">
  <pre class="nyan-json">{{ .ResultJSON }}</pre>
</div>
```

**htmx 例**
```html
<div hx-get="/list?format=html" hx-target="#list" hx-swap="innerHTML"></div>
```

---

## アクセス方法 {#アクセス方法}

- HTTP: `http://localhost:{Port}/?api=API名`
- HTTPS: `https://localhost:{Port}/?api=API名`
- エンドポイント形式: `/API名` も同様

---

## JSON-RPC サポート {#json-rpc-サポート}

- エンドポイント: `/nyan-rpc`
- JSON-RPC 2.0 準拠(batchは未実装)

---

## 予約語 {#予約語}

`api`、`nyan` から始まる名前は予約語です。パラメータに使用しないでください。
