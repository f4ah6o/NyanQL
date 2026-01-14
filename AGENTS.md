# Repository Guidelines

## Project Structure & Module Organization
- `main.go` is the Go entry point for the HTTP/WebSocket API service.
- `config.json` and `api.json` live in the repo root and are loaded relative to the executable path.
- `sql/` holds database-specific SQL templates (`sql/{mysql,postgres,sqlite}`) referenced by `api.json`.
- `javascript/` contains `check` and `script` files plus shared helpers in `javascript/lib/`.
- `templates/` contains Go `html/template` files for HTML/htmx responses; `ssl/` and `logs/` hold local certs and log output; `stamps.db` is a sample SQLite DB.

## Build, Test, and Development Commands
- `go build -o NyanQL .` builds a local binary in the repo root.
- `./NyanQL` runs the server; keep `config.json` and `api.json` next to the binary.
- `./build.sh` cross-compiles release binaries (macOS/Windows; adjust toolchains as needed).
- `go test ./...` runs Go tests (none currently).
- `gofmt -w main.go` formats Go sources.
- Use Go 1.24 toolchain as declared in `go.mod`.

## Coding Style & Naming Conventions
- Go code follows gofmt defaults (tabs, mixedCaps identifiers). Keep exported JSON field tags stable.
- JavaScript files use 4-space indentation and return `JSON.stringify({...})` from `main()`.
- SQL templates must use the project syntax: `/*param*/` placeholders and `/*IF ...*/ ... /*END*/` blocks.
- Place new SQL under `sql/<db>/` and reference via `api.json` entries.

## Testing Guidelines
- No automated tests exist yet. If you add tests, use Go's `*_test.go` naming in the same folder and run `go test ./...`.
- Validate JS `check`/`script` behavior through the API endpoints they back.

## Commit & Pull Request Guidelines
- Commit history uses short, imperative summaries in either English or Japanese; no conventional prefixes.
- PRs should include a brief change summary, verification steps (build/run), and note any `config.json`, `api.json`, SQL, or template changes. Include example requests/responses when API behavior changes.

## Configuration & Security Notes
- `config.json` includes DB and BasicAuth settings; avoid committing real credentials.
- Paths in `config.json`/`api.json` are resolved relative to the executable; keep related assets alongside the built binary.
