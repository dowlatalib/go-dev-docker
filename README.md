# Go Development Environment

Development environment dengan Docker, Air (hot reload), golang-migrate, SQLC, dan Swagger.

## Prerequisites

- Docker & Docker Compose
- Make (optional, tapi sangat disarankan)

## Quick Start

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Build dan start containers
make build
make up

# 3. Jalankan migrations
make migrate-up

# 4. Generate SQLC code
make sqlc-generate

# 5. Generate Swagger docs
make swagger-generate

# 6. Lihat logs
make logs
```

## File Ownership

Setup ini memastikan semua file yang digenerate oleh container (migrations, sqlc, swagger) tetap dimiliki oleh user host, bukan root.

Caranya adalah dengan passing `USER_ID` dan `GROUP_ID` ke container:

```bash
# Makefile sudah handle ini secara otomatis
make build
make up

# Atau manual:
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose up -d
```

## Available Commands

### Docker

| Command | Description |
|---------|-------------|
| `make build` | Build Docker images dengan UID/GID host |
| `make up` | Start semua containers |
| `make down` | Stop semua containers |
| `make restart` | Restart app container |
| `make logs` | View logs (follow mode) |
| `make shell` | Open bash shell di app container |

### Database Migrations

| Command | Description |
|---------|-------------|
| `make migrate-create name=xxx` | Buat migration baru |
| `make migrate-up` | Jalankan semua pending migrations |
| `make migrate-down` | Rollback 1 migration |
| `make migrate-force v=xxx` | Force set version |
| `make migrate-version` | Lihat current version |

### Code Generation

| Command | Description |
|---------|-------------|
| `make sqlc-generate` | Generate Go code dari SQL queries |
| `make swagger-generate` | Generate Swagger documentation |
| `make generate` | Jalankan semua code generation |

### Development

| Command | Description |
|---------|-------------|
| `make test` | Run tests |
| `make test-coverage` | Run tests dengan coverage report |
| `make lint` | Run linter |
| `make clean` | Hapus generated files |
| `make clean-volumes` | Stop containers dan hapus volumes |

## Project Structure

```
.
├── cmd/
│   └── api/
│       └── main.go          # Application entrypoint
├── internal/
│   └── db/
│       ├── queries/         # SQLC query files (.sql)
│       └── sqlc/            # Generated SQLC code
├── migrations/              # Database migrations
├── docs/                    # Generated Swagger docs
├── tmp/                     # Air build output
├── .air.toml               # Air configuration
├── docker-compose.yml
├── Dockerfile
├── entrypoint.sh
├── go.mod
├── Makefile
└── sqlc.yaml               # SQLC configuration
```

## Hot Reload

Air akan otomatis rebuild dan restart aplikasi ketika ada perubahan pada:
- File `.go`
- File `.sql` (untuk detect perubahan queries)
- File template (`.tpl`, `.tmpl`, `.html`)

Konfigurasi ada di `.air.toml`.

## Swagger

Akses Swagger UI di: http://localhost:8080/swagger/

Untuk update documentation:
```bash
make swagger-generate
```

## Database

PostgreSQL running di port `5432` dengan credentials:
- Host: `localhost` (dari host) atau `db` (dari container)
- User: `postgres`
- Password: `postgres`
- Database: `app_dev`

Connection string:
```
postgres://postgres:postgres@localhost:5432/app_dev?sslmode=disable
```

## Troubleshooting

### Permission Issues

Jika masih ada permission issues:

```bash
# Check current UID/GID
id -u  # USER_ID
id -g  # GROUP_ID

# Rebuild dengan explicit values
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose build --no-cache
USER_ID=$(id -u) GROUP_ID=$(id -g) docker compose up -d
```

### Container tidak bisa start

```bash
# Check logs
docker compose logs app

# Rebuild fresh
make clean-volumes
make build
make up
```

### SQLC errors

Pastikan migrations sudah dijalankan sebelum generate SQLC:
```bash
make migrate-up
make sqlc-generate
```
