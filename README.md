# Go Dev Docker

A Docker-based development environment for Go backend applications with PostgreSQL database and MinIO object storage integration.

## Features

- **Live Code Reloading**: Automatic recompilation on code changes using [Air](https://github.com/cosmtrek/air)
- **Database Integration**: PostgreSQL with multiple database support
- **Object Storage**: MinIO for file storage
- **API Documentation**: Swagger documentation generation
- **VS Code Dev Containers**: Seamless IDE integration for containerized development

## Prerequisites

- Docker 20.10+
- Docker Compose 1.29+
- VS Code with Dev Containers extension (optional)

## Project Structure

```
go-dev-docker/
├── backend/                 # Go application backend
│   ├── cmd/server/         # Application entrypoint
│   ├── docs/               # Generated documentation
│   ├── .air.toml           # Live reload configuration
│   └── go.mod              # Go module definition
├── frontend/               # Frontend application
├── Dockerfile              # Development container definition
├── docker-compose.yml      # Multi-container orchestration
└── .devcontainer/          # VS Code dev container config
```

## Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd go-dev-docker
   ```

2. **Start the development environment**
   ```bash
   docker-compose up
   ```

3. **Access the application**
   - API: http://localhost:8080

## VS Code Development

1. Install the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
2. Open the project in VS Code
3. Click "Reopen in Container" when prompted
4. Dependencies will be automatically installed

## Development Tools

The Docker container includes:

| Tool | Description |
|------|-------------|
| [Air](https://github.com/cosmtrek/air) | Live reload for Go applications |
| [golang-migrate](https://github.com/golang-migrate/migrate) | Database migration tool |
| [sqlc](https://sqlc.dev/) | Type-safe SQL code generator |
| [swag](https://github.com/swaggo/swag) | Swagger documentation generator |
| [gopls](https://pkg.go.dev/golang.org/x/tools/gopls) | Go language server |

## Common Commands

```bash
# Start all services
docker-compose up

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild containers
docker-compose up --build

# Access container shell
docker-compose exec app sh
```

## License

[Add your license here]
