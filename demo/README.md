# NyanQL HTMX Demo

This demo uses Vite + HTMX for the UI and NyanQL (SQLite) as the backend.
It sends a message, stores it in SQLite, and renders HTML returned by NyanQL.

## What it shows

- `api.json` routes `/demo_message` to SQL templates and an HTML template.
- HTML responses come from `templates/demo_message.html` when `HX-Request` is set.
- Messages are stored in `stamps.db` via SQLite.
- The UI shows both the rendered HTML and the raw HTML response text.

## Setup

From the repo root, you can run:

```sh
make demo
```

To remove demo artifacts:

```sh
make demo-clean
```

This removes the built binary, Vite artifacts, and the demo `stamps.db`.

Manual steps:

1. Initialize the demo table (one time):

   ```sh
   sqlite3 ./stamps.db < ./sql/sqlite/demo_init.sql
   ```

2. Build and run NyanQL from the repo root:

   ```sh
   go build -o NyanQL .
   ./NyanQL
   ```

3. Start the Vite dev server:

   ```sh
   cd demo
   pnpm install
   pnpm dev
   ```

Open `http://localhost:5173` and submit a message.

## Notes

- The Vite dev server proxies `/demo_message` to `http://localhost:8443`.
- The form sends Basic Auth with the default credentials (`neko:nyan`).
  If you change `config.json`, update the header in `demo/index.html`.
