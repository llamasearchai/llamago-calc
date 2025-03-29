#!/bin/bash

# Get the directory where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to the correct directory
cd "$DIR"

# Run the client with default values if no arguments provided
if [ $# -eq 0 ]; then
  echo "Running LlamaCalc client with default values (addition of 5 and 3)..."
  go run cmd/basic_client/main.go -a 5 -b 3 -op add
else
  # Run with provided arguments
  echo "Running LlamaCalc client with provided arguments..."
  go run cmd/basic_client/main.go "$@"
fi 