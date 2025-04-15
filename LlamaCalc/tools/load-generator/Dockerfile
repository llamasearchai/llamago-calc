FROM golang:1.21-alpine AS builder

# Install necessary build tools
RUN apk add --no-cache git ca-certificates

# Install ghz - a gRPC benchmarking tool
RUN go install github.com/bojand/ghz/cmd/ghz@latest

# Final stage
FROM alpine:3.18

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata bash

# Copy ghz binary from builder stage
COPY --from=builder /go/bin/ghz /usr/local/bin/ghz

# Copy scripts
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"] 