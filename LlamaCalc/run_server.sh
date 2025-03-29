#!/bin/bash

# Get the directory where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to the correct directory
cd "$DIR"

# Run the server
echo "Running LlamaCalc server..."
go run cmd/server/main.go serve

# Run with arguments if provided
if [ $# -gt 0 ]; then
  go run cmd/server/main.go serve "$@"
fi 