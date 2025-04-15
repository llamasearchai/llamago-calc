#!/bin/bash

# Directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Function to print colored text
print_colored() {
  echo -e "\033[1;36m$1\033[0m"
}

print_error() {
  echo -e "\033[1;31m$1\033[0m"
}

print_success() {
  echo -e "\033[1;32m$1\033[0m"
}

check_server() {
  if lsof -i :50051 &> /dev/null; then
    SERVER_PID=$(lsof -i :50051 | grep LISTEN | awk '{print $2}')
    print_success "Server is running on port 50051 (PID: $SERVER_PID)"
    return 0
  else
    print_error "Server is not running"
    return 1
  fi
}

start_server() {
  if check_server &> /dev/null; then
    print_error "Server is already running"
    return 1
  fi
  
  print_colored "Starting gRPC server..."
  cd "$SCRIPT_DIR"
  nohup go run cmd/basic_server/main.go > server.log 2>&1 &
  sleep 2
  
  if check_server &> /dev/null; then
    print_success "Server started successfully"
    return 0
  else
    print_error "Failed to start server, check server.log for details"
    return 1
  fi
}

stop_server() {
  if ! check_server &> /dev/null; then
    print_error "Server is not running"
    return 1
  fi
  
  SERVER_PID=$(lsof -i :50051 | grep LISTEN | awk '{print $2}')
  print_colored "Stopping server (PID: $SERVER_PID)..."
  kill $SERVER_PID
  
  sleep 1
  
  if ! check_server &> /dev/null; then
    print_success "Server stopped successfully"
    return 0
  else
    print_error "Failed to stop server, killing forcefully..."
    kill -9 $SERVER_PID
    sleep 1
    
    if ! check_server &> /dev/null; then
      print_success "Server killed successfully"
      return 0
    else
      print_error "Failed to kill server"
      return 1
    fi
  fi
}

run_demo() {
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

  print_success "\nDemo completed successfully!"
}

# Check command-line arguments
if [ $# -eq 0 ]; then
  print_error "Usage: $0 {start|stop|status|demo|restart}"
  exit 1
fi

# Process command
case "$1" in
  start)
    start_server
    ;;
  stop)
    stop_server
    ;;
  status)
    check_server
    ;;
  demo)
    run_demo
    ;;
  restart)
    stop_server
    start_server
    ;;
  *)
    print_error "Unknown command: $1"
    print_error "Usage: $0 {start|stop|status|demo|restart}"
    exit 1
    ;;
esac 