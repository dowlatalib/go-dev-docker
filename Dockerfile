FROM golang:1.25.6-alpine

# Install required system packages
RUN apk add --no-cache \
    git \
    curl \
    bash \
    make \
    gcc \
    musl-dev

# Install golang-migrate
RUN go install -tags 'postgres mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Install sqlc
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# Install air (live reload)
RUN go install github.com/air-verse/air@latest

# Install swag (Swagger docs generator)
RUN go install github.com/swaggo/swag/cmd/swag@latest

# Install gopls (Go language server)
RUN go install golang.org/x/tools/gopls@latest

# Set working directory
WORKDIR /app

# Expose common development ports
EXPOSE 8080
