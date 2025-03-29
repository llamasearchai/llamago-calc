#!/bin/bash
set -e

# Default values
TARGET_HOST=${TARGET_HOST:-"localhost:50051"}
RATE=${RATE:-10}
DURATION=${DURATION:-"30s"}
TOTAL=${TOTAL:-0}
CONCURRENCY=${CONCURRENCY:-10}
METHOD=${METHOD:-"Add"}
SECURE=${SECURE:-"false"}
AUTH=${AUTH:-"none"}  # none, jwt, mtls
CERT_FILE=${CERT_FILE:-"/certs/client.crt"}
KEY_FILE=${KEY_FILE:-"/certs/client.key"}
CA_FILE=${CA_FILE:-"/certs/ca.crt"}
JWT_TOKEN=${JWT_TOKEN:-""}

echo "LlamaCalc Load Generator"
echo "======================="
echo "Target:      $TARGET_HOST"
echo "Method:      $METHOD"
echo "Rate:        $RATE requests/second"
echo "Duration:    $DURATION"
echo "Total:       $TOTAL requests (0 = unlimited)"
echo "Concurrency: $CONCURRENCY"
echo "Secure:      $SECURE"
echo "Auth:        $AUTH"
echo "======================="

# Prepare data payload based on method
case $METHOD in
  "Add")
    DATA='{"a": 42.5, "b": 17.8}'
    ;;
  "Subtract")
    DATA='{"a": 100.0, "b": 45.5}'
    ;;
  "Multiply")
    DATA='{"a": 12.5, "b": 4.0}'
    ;;
  "Divide")
    DATA='{"a": 84.0, "b": 2.0}'
    ;;
  *)
    echo "Unknown method: $METHOD"
    exit 1
    ;;
esac

# Build security options
SECURITY_OPTS=""
if [ "$SECURE" = "true" ]; then
  if [ "$AUTH" = "mtls" ]; then
    SECURITY_OPTS="-authority=llamacalc -cacert=${CA_FILE} -cert=${CERT_FILE} -key=${KEY_FILE}"
  elif [ "$AUTH" = "jwt" ]; then
    SECURITY_OPTS="-authority=llamacalc -metadata=authorization:Bearer\ ${JWT_TOKEN}"
  else
    SECURITY_OPTS="-insecure"
  fi
else
  SECURITY_OPTS="-insecure"
fi

# Build the command
CMD="ghz --proto=/protos/calculator.proto --call=llamacalc.Calculator.$METHOD $SECURITY_OPTS --data='$DATA' --rps=$RATE --connections=$CONCURRENCY --insecure"

# Add either duration or total
if [ "$TOTAL" -gt 0 ]; then
  CMD="$CMD --total=$TOTAL"
else
  CMD="$CMD --duration=$DURATION"
fi

# Add target
CMD="$CMD $TARGET_HOST"

echo "Running command: $CMD"
echo "======================="

# Execute the command
eval $CMD 