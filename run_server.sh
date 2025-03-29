#!/bin/bash

# Exit on error
set -e

# Set environment variables
export PORT=${PORT:-8080}
export TLS_ENABLED=${TLS_ENABLED:-false}
export MTLS_ENABLED=${MTLS_ENABLED:-false}
export CERT_FILE=${CERT_FILE:-"certs/server.crt"}
export KEY_FILE=${KEY_FILE:-"certs/server.key"}
export CA_FILE=${CA_FILE:-"certs/ca.crt"}

# Check if the main.go file exists
if [ ! -f "LlamaCalc/cmd/server/main.go" ]; then
    echo "Error: main.go not found at LlamaCalc/cmd/server/main.go"
    exit 1
fi

# Build and run the server
echo "Starting LlamaCalc server..."
cd LlamaCalc && go run cmd/server/main.go 