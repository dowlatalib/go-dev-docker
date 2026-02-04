.PHONY: help build up down restart logs shell \
        migrate-create migrate-up migrate-down migrate-force \
        sqlc-generate swagger-generate generate \
        test lint clean

# Default target
help:
	@echo "Available commands:"
	@echo ""
	@echo "Docker:"
	@echo "  make build          - Build Docker images"
	@echo "  make up             - Start containers"
	@echo "  make down           - Stop containers"
	@echo "  make restart        - Restart containers"
	@echo "  make logs           - View container logs"
	@echo "  make shell          - Open shell in app container"
	@echo ""
	@echo "Database Migrations:"
	@echo "  make migrate-create name=xxx  - Create new migration"
	@echo "  make migrate-up               - Run all pending migrations"
	@echo "  make migrate-down             - Rollback last migration"
	@echo "  make migrate-force v=xxx      - Force migration version"
	@echo ""
	@echo "Code Generation:"
	@echo "  make sqlc-generate     - Generate SQLC code"
	@echo "  make swagger-generate  - Generate Swagger docs"
	@echo "  make generate          - Run all code generation"
	@echo ""
	@echo "Development:"
	@echo "  make test           - Run tests"
	@echo "  make lint           - Run linter"
	@echo "  make clean          - Clean generated files"

# Docker commands
build:
	USER_ID=$$(id -u) GROUP_ID=$$(id -g) docker compose build

up:
	USER_ID=$$(id -u) GROUP_ID=$$(id -g) docker compose up -d

down:
	docker compose down

restart:
	docker compose restart app

logs:
	docker compose logs -f app

shell:
	docker compose exec app bash

# Database migration commands
migrate-create:
	@if [ -z "$(name)" ]; then \
		echo "Error: Please provide migration name. Usage: make migrate-create name=create_users_table"; \
		exit 1; \
	fi
	docker compose exec app migrate create -ext sql -dir migrations -seq $(name)

migrate-up:
	docker compose exec app migrate -path migrations -database "$${DATABASE_URL}" up

migrate-down:
	docker compose exec app migrate -path migrations -database "$${DATABASE_URL}" down 1

migrate-force:
	@if [ -z "$(v)" ]; then \
		echo "Error: Please provide version. Usage: make migrate-force v=1"; \
		exit 1; \
	fi
	docker compose exec app migrate -path migrations -database "$${DATABASE_URL}" force $(v)

migrate-version:
	docker compose exec app migrate -path migrations -database "$${DATABASE_URL}" version

# Code generation commands
sqlc-generate:
	docker compose exec app sqlc generate

swagger-generate:
	docker compose exec app swag init -g cmd/api/main.go -o cmd/docs --parseDependency --parseInternal

swagger-fmt:
	docker compose exec app swag fmt

generate: sqlc-generate swagger-generate
	@echo "All code generation completed!"

# Development commands
test:
	docker compose exec app go test -v ./...

test-coverage:
	docker compose exec app go test -coverprofile=coverage.out ./...
	docker compose exec app go tool cover -html=coverage.out -o coverage.html

lint:
	docker compose exec app golangci-lint run ./...

# Clean commands
clean:
	docker compose exec app rm -rf tmp/
	docker compose exec app rm -rf docs/

clean-volumes:
	docker compose down -v
