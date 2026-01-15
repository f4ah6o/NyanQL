SHELL := /bin/bash

SQLITE ?= sqlite3
GO ?= go
PNPM ?= pnpm

DEMO_DB := stamps.db
DEMO_INIT := sql/sqlite/demo_init.sql
DEMO_BIN := NyanQL
DEMO_DIR := demo

.PHONY: demo demo-init demo-build demo-server demo-ui demo-clean

demo-init:
	$(SQLITE) $(DEMO_DB) < $(DEMO_INIT)

demo-build:
	$(GO) build -o $(DEMO_BIN) .

demo-server: demo-build
	./$(DEMO_BIN)

demo-ui:
	cd $(DEMO_DIR) && $(PNPM) install && $(PNPM) dev

demo-clean:
	rm -rf $(DEMO_BIN) $(DEMO_DB) $(DEMO_DIR)/node_modules $(DEMO_DIR)/dist $(DEMO_DIR)/.vite

demo: demo-init demo-build
	@set -euo pipefail; \
	./$(DEMO_BIN) & \
	server_pid=$$!; \
	trap 'kill $$server_pid' INT TERM EXIT; \
	cd $(DEMO_DIR) && $(PNPM) install && $(PNPM) dev
