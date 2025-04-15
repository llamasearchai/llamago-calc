# Builder stage
FROM golang:1.21-alpine AS builder

# Install necessary build tools
RUN apk add --no-cache git ca-certificates tzdata make

# Set working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application with optimizations
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s -X 'main.Version=$(git describe --tags --always)' -X 'main.BuildTime=$(date -u +'%Y-%m-%dT%H:%M:%SZ')'" \
    -o /go/bin/llamacalc ./cmd/server

# Final stage
FROM alpine:3.18

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install runtime dependencies 
RUN apk add --no-cache ca-certificates tzdata

# Set working directory
WORKDIR /app

# Copy binary from builder stage
COPY --from=builder /go/bin/llamacalc /app/llamacalc

# Copy necessary config files
COPY config/config.yaml /app/config/
COPY certs/server.crt /app/certs/
COPY certs/server.key /app/certs/

# Set ownership
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 50051

# Default health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["/app/llamacalc", "health"]

# Set entrypoint
ENTRYPOINT ["/app/llamacalc"]

# Default command
CMD ["serve", "--config", "/app/config/config.yaml"] 