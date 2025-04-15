#!/bin/bash

# Exit on any error
set -e

# Directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to print colored text
print_colored() {
  echo -e "\033[1;36m$1\033[0m"
}

# Check if server is already running
if lsof -i :50051 &> /dev/null; then
  print_colored "Server is already running on port 50051, using it..."
  SERVER_RUNNING=true
else
  # Kill any lingering processes
  print_colored "Starting new gRPC server..."
  cd "$SCRIPT_DIR"
  go run cmd/basic_server/main.go &
  SERVER_PID=$!
  SERVER_RUNNING=false
  
  # Wait for server to start
  print_colored "Waiting for server to start..."
  sleep 2
fi

# Run client demos
print_colored "Running client demos..."
cd "$SCRIPT_DIR"

print_colored "\nTesting addition (5 + 3):"
go run cmd/basic_client/main.go -op add -a 5 -b 3

print_colored "\nTesting subtraction (10 - 4):"
go run cmd/basic_client/main.go -op subtract -a 10 -b 4

print_colored "\nTesting multiplication (7 * 6):"
go run cmd/basic_client/main.go -op multiply -a 7 -b 6

print_colored "\nTesting division (20 / 5):"
go run cmd/basic_client/main.go -op divide -a 20 -b 5

print_colored "\nTesting division by zero (10 / 0):"
go run cmd/basic_client/main.go -op divide -a 10 -b 0

# Kill the server if we started it
if [ "$SERVER_RUNNING" = false ]; then
  print_colored "\nKilling server..."
  kill $SERVER_PID || true
fi

print_colored "\nDemo completed successfully!" 