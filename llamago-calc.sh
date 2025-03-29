#!/bin/bash

# Get the directory where the script is located
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change to the LlamaCalc directory
cd "$DIR/LlamaCalc"

# Show usage if no arguments provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 [server|client] [args...]"
  echo ""
  echo "Commands:"
  echo "  server   Start the LlamaCalc server"
  echo "  client   Run the LlamaCalc client with optional arguments"
  echo ""
  echo "Examples:"
  echo "  $0 server                    # Start the server"
  echo "  $0 client                    # Run client with default arguments"
  echo "  $0 client -a 10 -b 5 -op multiply # Run client with custom arguments"
  exit 1
fi

# Get the command
COMMAND=$1
shift

# Execute the appropriate script
case $COMMAND in
  server)
    ./run_server.sh "$@"
    ;;
  client)
    ./run_client.sh "$@"
    ;;
  *)
    echo "Unknown command: $COMMAND"
    echo "Use 'server' or 'client'"
    exit 1
    ;;
esac 