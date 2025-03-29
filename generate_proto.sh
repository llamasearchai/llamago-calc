#!/bin/bash

# Exit on error
set -e

# Make sure Go binaries are in PATH
export PATH=$PATH:$(go env GOPATH)/bin

# Install protoc if not installed
if ! command -v protoc &> /dev/null; then
    echo "protoc not found. Please install Protocol Buffers compiler."
    exit 1
fi

# Install required Go plugins if not already installed
echo "Installing required Go plugins..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

# Generate Go code from proto files
echo "Generating Go code from proto files..."
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       LlamaCalc/pkg/proto/*.proto

echo "Proto generation completed successfully!" 