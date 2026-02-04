# Development Dockerfile for Go with Air, Migrate, SQLC, Swagger, and LSPs
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

# Install gopls (Go language server)
RUN go install golang.org/x/tools/gopls@latest

# Install sqls (SQL language server) — requires CGO for godror (Oracle driver)
RUN apk add --no-cache gcc musl-dev && \
    CGO_ENABLED=1 go install github.com/sqls-server/sqls@latest && \
    apk del gcc musl-dev

# Copy Go binaries to a shared location
RUN cp /go/bin/* /usr/local/bin/

# Install latest Node.js via official Alpine package
RUN apk add --no-cache nodejs npm

# Configure npm for devuser: prefix, cache, and PATH
ENV NPM_CONFIG_PREFIX=/home/devuser/.npm-global
ENV NPM_CONFIG_CACHE=/home/devuser/.npm-cache
ENV PATH="${NPM_CONFIG_PREFIX}/bin:${PATH}"

# Create npm directories owned by devuser
RUN mkdir -p /home/devuser/.npm-global /home/devuser/.npm-cache && \
    chown -R devuser:devgroup /home/devuser/.npm-global /home/devuser/.npm-cache

# Install language servers for Node.js/TS, Vue, and Svelte
RUN su-exec devuser npm install -g \
    typescript \
    typescript-language-server \
    @vue/language-server \
    svelte-language-server

# Set working directory
WORKDIR /app

# Create directories that might be needed
RUN mkdir -p /go/pkg/mod /app/backend /app/frontend && \
    chown -R devuser:devgroup /go /app/backend /app/frontend

# Entrypoint script to handle permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
