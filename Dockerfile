# Development Dockerfile for Go with Air, Migrate, SQLC, and Swagger
FROM golang:1.25.6-alpine

# Build arguments for user mapping
ARG USER_ID=1000
ARG GROUP_ID=1000

# Install essential packages
RUN apk add --no-cache \
    git \
    curl \
    make \
    bash \
    shadow \
    su-exec

# Create group and user with same UID/GID as host
RUN if getent group ${GROUP_ID} > /dev/null 2>&1; then \
    delgroup $(getent group ${GROUP_ID} | cut -d: -f1); \
    fi && \
    if getent passwd ${USER_ID} > /dev/null 2>&1; then \
    deluser $(getent passwd ${USER_ID} | cut -d: -f1); \
    fi && \
    addgroup -g ${GROUP_ID} devgroup && \
    adduser -D -u ${USER_ID} -G devgroup -s /bin/bash devuser

# Install Air (hot reload)
RUN go install github.com/air-verse/air@latest

# Install golang-migrate
RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Install SQLC
RUN go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest

# Install Swag (Swagger generator)
RUN go install github.com/swaggo/swag/cmd/swag@latest

# Copy Go binaries to a shared location
RUN cp /go/bin/* /usr/local/bin/

# Set working directory
WORKDIR /app

# Create directories that might be needed
RUN mkdir -p /go/pkg/mod && \
    chown -R devuser:devgroup /go

# Entrypoint script to handle permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["air", "-c", ".air.toml"]
